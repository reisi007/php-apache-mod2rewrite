# Default to 8.2 if no argument is provided
ARG PHP_VERSION=8.2

# Use the variable in the FROM line
FROM php:${PHP_VERSION}-apache

# 1. Enable mod_rewrite for URL rewriting
RUN a2enmod rewrite

# 2. Update Apache config to allow .htaccess to override settings
# This replaces "AllowOverride None" with "AllowOverride All" specifically for /var/www/
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# (Optional) Install common PHP extensions required by many apps (GD, MySQL, ZIP, etc.)
# If your apps need specific extensions, add them here.
RUN docker-php-ext-install mysqli pdo pdo_mysql
