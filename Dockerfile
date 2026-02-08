# Default to 8.2 if no argument is provided
ARG PHP_VERSION=8.2
# 1. System-Pakete installieren
# NEU: libwebp-dev und libavif-dev hinzugefügt
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
# NEU: --with-webp und --with-avif Flags hinzugefügt
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

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN echo '<Directory /var/www/html>' >> /etc/apache2/conf-available/docker-php-htaccess.conf \
    && echo '    AllowOverride All' >> /etc/apache2/conf-available/docker-php-htaccess.conf \
    && echo '</Directory>' >> /etc/apache2/conf-available/docker-php-htaccess.conf \
    && a2enconf docker-php-htaccess
