FROM php:7.0-fpm

RUN set -ex \
    && echo "deb http://us.archive.ubuntu.com/ubuntu/ wily main" >> /etc/apt/sources.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 40976EAF437D05B5 3B4FE6ACC0B21F32 60C60AA4 \
    && apt-get update && apt-get install -y git libgmp-dev libpq-dev libfreetype6-dev libjpeg62-turbo-dev  libmcrypt-dev libpng12-dev libmemcached-dev curl \
    && apt-get install nodejs -y \
    && apt-get install npm -y \
    && npm install -g bower \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/php7.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-php7 /usr/src/php/ext/redis \
    && yes 'no' | pecl install -f apcu-5.1.5 \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable apcu \
    && docker-php-ext-install redis gmp pdo pdo_pgsql opcache zip \
    && rm -rf /usr/src/php/ext/redis /tmp/redis.tar.gz \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && echo "{}" > ~/.composer/composer.json

# Install Memcached for php 7
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

COPY symfony.ini /usr/local/etc/php/conf.d/

EXPOSE 9000
CMD ["php-fpm"]

ENV COMPOSER_HOME /root/composer
ARG GITHUB_TOKEN

ADD app/ /var/www/html
WORKDIR /var/www/html

RUN composer update -vvv -o && \
    bower update && \
    php app/console assets:install web --symlink && \
    php app/console assetic:dump && \
    chmod -R 777 app/cache app/logs && \
    php app/console doctrine:schema:drop --force && \
    php app/console doctrine:schema:create && \
    php app/console ojs:install && \
    php app/console ojs:install:samples && \
    php app/console h4cc_alice_fixtures:load:sets && \
    composer show

CMD php-fpm
