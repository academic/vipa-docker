FROM php:7.0-fpm-alpine
RUN apk update && apk add git

ENV COMPOSER_HOME /root/composer
ARG GITHUB_TOKEN

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

ADD app/ /var/www/html
WORKDIR /var/www/html/web

RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN docker-php-ext-install intl && docker-php-ext-enable intl && \
    docker-php-ext-install memcached && docker-php-ext-enable memcached

RUN composer update -vvv -o && \
    bower update && \
    php app/console assets:install web --symlink && \
    php app/console assetic:dump && \
    php app/console doctrine:schema:drop --force && \
    php app/console doctrine:schema:create && \
    php app/console ojs:install && \
    php app/console ojs:install:samples

CMD php-fpm
