# PHP Version
ARG PHP_VERSION=8.3

# --- Stage: Base (php-apache-mod2rewrite) ---
FROM php:${PHP_VERSION}-apache AS base

# Apache Mod-Rewrite
RUN a2enmod rewrite

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

# --- Stage: Full (php-apache-mod2rewrite-imagick-exiftool) ---
FROM base AS full

# System dependencies
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

# PHP Extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-avif \
    && docker-php-ext-install -j$(nproc) gd zip exif

# Imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# PHP Config (8GB RAM Optimization)
RUN echo "memory_limit = 1024M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 16M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 16M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/uploads.ini

# ImageMagick Policies (RAM limits & disable AVIF/HEIC)
RUN find /etc -name "policy.xml" -exec sed -i 's/limit memory="256MiB"/limit memory="4GiB"/g' {} + \
    && find /etc -name "policy.xml" -exec sed -i 's/limit map="512MiB"/limit map="4GiB"/g' {} + \
    && find /etc -name "policy.xml" -exec sed -i '/<\/policymap>/i \  <policy domain="coder" rights="none" pattern="AVIF" />' {} + \
    && find /etc -name "policy.xml" -exec sed -i '/<\/policymap>/i \  <policy domain="coder" rights="none" pattern="HEIC" />' {} +