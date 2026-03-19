# PHP Version
ARG PHP_VERSION=8.3

# --- Stage: Base (php-apache-mod2rewrite) ---
FROM php:${PHP_VERSION}-apache AS base

# System dependencies for Base (xsendfile)
RUN apt-get update && apt-get install -y \
    libapache2-mod-xsendfile \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# Apache Mod-Rewrite & Mod-XSendfile
RUN a2enmod rewrite xsendfile

# Configure X-Sendfile to allow serving from /var/www (covers /var/www/html and /var/www/photos)
RUN echo "XSendFile On\nXSendFilePath /var/www" > /etc/apache2/conf-available/xsendfile.conf \
    && a2enconf xsendfile

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

# --- Stage: Base with MariaDB PDO (-maria-pdo) ---
FROM base AS base-maria-pdo

# MariaDB/MySQL PDO Treiber installieren
RUN docker-php-ext-install pdo_mysql

# --- Stage: Full (php-apache-mod2rewrite-imagick-exiftool) ---
FROM base AS full

# System dependencies for Media Processing
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
RUN docker-php-ext-configure gd --with-freetype \
    --with-jpeg --with-webp --with-avif \
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

# --- Stage: Full with MariaDB PDO (-maria-pdo) ---
FROM full AS full-maria-pdo

# MariaDB/MySQL PDO Treiber installieren
RUN docker-php-ext-install pdo_mysql