# Wir definieren ein Argument (Standard 8.3), das von außen überschrieben werden kann
ARG PHP_VERSION=8.3

# WICHTIG: Hier nutzen wir das Argument. Ohne diese Zeile (FROM) geht gar nichts!
FROM php:${PHP_VERSION}-apache

# 1. System-Pakete installieren (inkl. WebP/AVIF Support)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libwebp-dev \
    libavif-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 2. PHP-Extensions konfigurieren & installieren
# Wir konfigurieren GD mit allen Flags für moderne Bildformate
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-avif \
    && docker-php-ext-install -j$(nproc) \
       gd \
       zip \
       intl \
       mysqli \
       pdo_mysql \
       exif \
       opcache

# 3. Apache mod_rewrite aktivieren
RUN a2enmod rewrite

# 4. PHP-Limits erhöhen (Uploads bis 64MB)
RUN echo "upload_max_filesize = 64M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini

# 5. Apache Document Root & .htaccess Erlaubnis
ENV APACHE_DOCUMENT_ROOT /var/www/html

# Pfade in den Apache-Configs dynamisch anpassen
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# AllowOverride All setzen, damit .htaccess funktioniert
RUN echo '<Directory /var/www/html>' >> /etc/apache2/conf-available/docker-php-htaccess.conf \
    && echo '    AllowOverride All' >> /etc/apache2/conf-available/docker-php-htaccess.conf \
    && echo '</Directory>' >> /etc/apache2/conf-available/docker-php-htaccess.conf \
    && a2enconf docker-php-htaccess
