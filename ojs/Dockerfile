FROM php:5.6.27-fpm-alpine
RUN apk update && apk add git

ENV COMPOSER_HOME /root/composer
ARG GITHUB_TOKEN

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

RUN echo "memory_limit=10024M" > /usr/local/etc/php/conf.d/memory-limit.ini

ADD http://raw.githubusercontent.com/ojs/ojs/master/composer.json /var/www/html
WORKDIR /var/www/html

RUN composer config github-oauth.github.com ${GITHUB_TOKEN}
RUN composer install 

ENV GITHUB_TOKEN unset
RUN apk del git expat pcre
CMD php-fpm