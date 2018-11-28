FROM php:7.2-fpm

COPY config/custom.ini /usr/local/etc/php/conf.d/

RUN apt-get update && apt-get install -y openssl git libxml2-dev zlib1g-dev libicu-dev g++ unzip supervisor

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime && echo Europe/Paris > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', Europe/Paris > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# Install the available extensions
# Sockets is for AMQP RabitMQ ?
# SOAP validation VAT Number
RUN docker-php-ext-install sockets pdo pdo_mysql intl soap

# Configure short open tag for Symfony
RUN echo "short_open_tag = Off" >> /usr/local/etc/php/php.ini

RUN usermod -u 1000 www-data 

# Supervisor
RUN mkdir -p /var/log/supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD supervisord -c /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html
