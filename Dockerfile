# Wir definieren ein Argument (Standard 8.3), das von außen überschrieben werden kann
ARG PHP_VERSION=8.3

# WICHTIG: Hier nutzen wir das Argument. Ohne diese Zeile (FROM) geht gar nichts!
FROM php:${PHP_VERSION}-apache

# 1. System-Abhängigkeiten installieren
# libavif-dev -> Wichtig für AVIF Support!
# libmagickwand-dev -> Wichtig für SVG/Imagick Support
# libzip-dev -> Für ZIP Download
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    libzip-dev \
    libmagickwand-dev --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# 2. GD Extension konfigurieren (Verknüpfung der Libraries)
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-avif

# 3. Standard PHP Extensions installieren
RUN docker-php-ext-install -j$(nproc) gd zip exif

# 4. Imagick Extension (via PECL) installieren und aktivieren
RUN pecl install imagick && docker-php-ext-enable imagick

# 5. Apache Mod-Rewrite aktivieren (für Clean URLs / .htaccess)
RUN a2enmod rewrite

# 6. PHP Konfiguration anpassen
# Erhöhe Limits für große Bilder (48MP benötigen viel RAM beim Verarbeiten!)
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini

# Arbeitsverzeichnis setzen
WORKDIR /var/www/html

# (Optional) Rechte setzen, damit www-data schreiben kann
# Dies wird meistens zur Laufzeit geregelt, aber hier als Vorbereitung:
RUN chown -R www-data:www-data /var/www/html
