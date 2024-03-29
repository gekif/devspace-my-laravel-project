FROM php:7.1-apache-stretch

# Set working directory
WORKDIR /var/www/html

# Install PDO MySQL driver
RUN docker-php-ext-install pdo_mysql

# Install git, zip and composer + enable Apache modules: rewrite, headers
RUN apt update \
 && apt install -y git zip \
 && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && a2enmod rewrite headers

# Copy files to WORKDIR and install dependencies
COPY . .
RUN composer install

# Set www-data as owner for files
RUN usermod -u 1000 www-data; \
    chown -R www-data:www-data /var/www/html

# Apache is listening on port 80
EXPOSE 80

# Change Apache root directory

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
