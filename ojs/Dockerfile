FROM php:5.6.27-fpm-alpine
RUN apk update && apk add git

ENV COMPOSER_HOME /root/composer
ARG GITHUB_TOKEN

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

ADD app/ /var/www/html
WORKDIR /var/www/html/web
CMD php-fpm
