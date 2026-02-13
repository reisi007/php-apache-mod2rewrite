# Wir definieren ein Argument (Standard 8.3), das von außen überschrieben werden kann
ARG PHP_VERSION=8.3

FROM php:${PHP_VERSION}-apache

# 1. System-Abhängigkeiten installieren
# libimage-exiftool-perl -> Installiert das Exiftool
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    libheif-dev \
    libzip-dev \
    libmagickwand-dev \
    libimage-exiftool-perl \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# 2. GD Extension konfigurieren (MIT AVIF Support)
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
RUN echo "memory_limit = 1024M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 16M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 16M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/uploads.ini

# 7. ImageMagick Konfiguration: RAM Limits anheben UND AVIF DEAKTIVIEREN
# Wir setzen die Rechte für AVIF und HEIC auf "none", damit Imagick sie ignoriert.
RUN find /etc -name "policy.xml" -exec sed -i 's/limit memory="256MiB"/limit memory="4GiB"/g' {} + \
    && find /etc -name "policy.xml" -exec sed -i 's/limit map="512MiB"/limit map="4GiB"/g' {} + \
    && find /etc -name "policy.xml" -exec sed -i '/<\/policymap>/i \  <policy domain="coder" rights="none" pattern="AVIF" />' {} + \
    && find /etc -name "policy.xml" -exec sed -i '/<\/policymap>/i \  <policy domain="coder" rights="none" pattern="HEIC" />' {} +

WORKDIR /var/www/html

# Rechte setzen
RUN chown -R www-data:www-data /var/www/html
