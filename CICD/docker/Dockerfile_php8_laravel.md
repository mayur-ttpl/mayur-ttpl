FROM alpine:3.17.1
LABEL maintainer="Store4U Team<support@mayur.in>"

# Set current work directory
WORKDIR /var/www/html/

# Essentials
RUN echo "UTC" > /etc/timezone
RUN apk add --no-cache zip unzip curl sqlite nginx supervisor

# Installing bash
RUN apk add bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing PHP
RUN apk add --no-cache php \
    php-common \
    php-fpm \
    php-pdo \
    php-gd \
    php-opcache \
    php-zip \
    php-phar \
    php-iconv \
    php-cli \
    php-curl \
    php-openssl \
    php-mbstring \
    php-tokenizer \
    php-fileinfo \
    php-json \
    php-xml \
    php-xmlwriter \
    php-simplexml \
    php-dom \
    php-pdo_mysql \
    php-pdo_sqlite \
    php-tokenizer \
    php81-pecl-redis

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Configure supervisor
RUN mkdir -p /etc/supervisor.d/
COPY docker/supervisord.ini /etc/supervisor.d/supervisord.ini

# Configure PHP
RUN mkdir -p /run/php/
RUN touch /run/php/php81-fpm.pid

COPY docker/php-fpm.conf /etc/php81/php-fpm.conf
COPY docker/php.ini-production /etc/php81/php.ini

# Verify the copied files on docker container
RUN ls -l /etc/php81 
RUN ls -l /etc/supervisor.d/
RUN ls -l /var/run/php/

# Configure nginx
COPY docker/nginx.conf /etc/nginx/
COPY docker/nginx-laravel.conf /etc/nginx/modules/

# Set service pid
RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Building process
COPY . .
RUN composer update && composer install --no-dev
RUN composer dump-autoload \ 
	&& php artisan config:clear \ 
	&& php artisan view:clear \ 
	&& php artisan cache:clear \
	&& php artisan route:clear

RUN chown -R nobody:nobody /var/www/html/storage
RUN chmod -R 777 storage && chmod -R 777 bootstrap/cache

# EXPOSE APPLICATION PORT
EXPOSE 80

# RUN COMMAND AT ENTRYPOINT
CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
