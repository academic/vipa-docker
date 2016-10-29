FROM php:5.6.27-fpm-alpine
RUN apk update && apk add git

ENV COMPOSER_HOME /root/composer
ARG GITHUB_TOKEN

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

RUN echo "memory_limit=10024M" > /usr/local/etc/php/conf.d/memory-limit.ini

WORKDIR /var/www/html
ADD app/ /var/www/html
CMD php-fpm