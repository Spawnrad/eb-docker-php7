FROM php:7.2-fpm

COPY config/custom.ini /usr/local/etc/php/conf.d/

RUN apt-get update && apt-get install -y openssl git libxml2-dev zlib1g-dev libicu-dev g++ unzip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime && echo Europe/Paris > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', Europe/Paris > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# Install APCu v5.1.7
RUN mkdir -p /usr/src/php/ext
RUN curl -L -o /tmp/apcu-5.1.7.tgz https://pecl.php.net/get/apcu-5.1.7.tgz
RUN tar xfz /tmp/apcu-5.1.7.tgz
RUN rm -r /tmp/apcu-5.1.7.tgz
RUN mv apcu-5.1.7  /usr/src/php/ext/apcu

# Install the available extensions
# Sockets is for AMQP RabitMQ ?
# SOAP validation VAT Number
RUN docker-php-ext-install sockets pdo pdo_mysql intl apcu soap

# Enable apc
RUN echo "apc.enable_cli = On" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

# install and active xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.max_nesting_level=9999" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Configure short open tag for Symfony
RUN echo "short_open_tag = Off" >> /usr/local/etc/php/php.ini

RUN usermod -u 1000 www-data 

WORKDIR /var/www/html