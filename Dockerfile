# Wir definieren ein Argument (Standard 8.3), das von außen überschrieben werden kann
ARG PHP_VERSION=8.3

FROM php:${PHP_VERSION}-apache

# 1. System-Abhängigkeiten installieren
# libheif-dev & libavif-dev -> WICHTIG für AVIF Support in ImageMagick/GD
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    libheif-dev \
    libzip-dev \
    libmagickwand-dev --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# 2. GD Extension konfigurieren (als Fallback)
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-avif

# 3. PHP Extensions installieren
RUN docker-php-ext-install -j$(nproc) gd zip exif

# 4. Imagick Extension installieren & aktivieren
RUN pecl install imagick && docker-php-ext-enable imagick

# 5. Apache Mod-Rewrite aktivieren
RUN a2enmod rewrite

# 6. PHP Konfiguration (Optimiert für 8GB RAM Server)
# upload/post bleiben klein (16M), aber memory_limit wird für AVIF-Encoding auf 1GB erhöht.
RUN echo "memory_limit = 1024M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 16M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 16M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/uploads.ini

# 7. CRITICAL FIX: ImageMagick Policy Limits anheben
# Standardmäßig begrenzt ImageMagick im Container den RAM oft auf 256MB.
# Da du 8GB hast, erlauben wir ImageMagick hier bis zu 4GB für die Verarbeitung.
RUN sed -i 's/domain="resource" name="memory" value="256MiB"/domain="resource" name="memory" value="4GiB"/' /etc/ImageMagick-6/policy.xml || true \
    && sed -i 's/domain="resource" name="map" value="512MiB"/domain="resource" name="map" value="4GiB"/' /etc/ImageMagick-6/policy.xml || true

# Falls ImageMagick 7 oder anderer Pfad: Wir suchen und patchen sicherheitshalber alle policy.xml Dateien
RUN find /etc -name "policy.xml" -exec sed -i 's/limit memory="256MiB"/limit memory="4GiB"/g' {} + \
    && find /etc -name "policy.xml" -exec sed -i 's/limit map="512MiB"/limit map="4GiB"/g' {} +

WORKDIR /var/www/html

# Rechte setzen
RUN chown -R www-data:www-data /var/www/html
