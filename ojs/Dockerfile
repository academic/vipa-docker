FROM php:7.0-fpm

RUN set -ex \
    && echo "deb http://us.archive.ubuntu.com/ubuntu/ wily main" >> /etc/apt/sources.list \
    && echo "deb http://ppa.launchpad.net/pinepain/libv8-5.2/ubuntu wily main " >> /etc/apt/sources.list \
    && echo "deb-src http://ppa.launchpad.net/pinepain/libv8-5.2/ubuntu wily main" >> /etc/apt/sources.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 40976EAF437D05B5 3B4FE6ACC0B21F32 60C60AA4 \
    && apt-get update && apt-get install -y git libgmp-dev libpq-dev libv8-5.2-dev \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/php7.tar.gz \
    && curl -L -o /tmp/v8js.tar.gz https://github.com/phpv8/v8js/archive/1.3.2.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && tar xfz /tmp/v8js.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-php7 /usr/src/php/ext/redis \
    && mv v8js-1.3.2 /usr/src/php/ext/v8js \
    && yes 'no' | pecl install -f apcu-5.1.5 \
    && docker-php-ext-enable apcu \
    && docker-php-ext-install v8js redis gmp pdo pdo_pgsql opcache zip \
    && rm -rf /usr/src/php/ext/redis /tmp/redis.tar.gz /usr/src/php/ext/v8js /tmp/v8js.tar.gz \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY symfony.ini /usr/local/etc/php/conf.d/

EXPOSE 9000
CMD ["php-fpm"]

ENV COMPOSER_HOME /root/composer
ARG GITHUB_TOKEN

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


ADD app/ /var/www/html
WORKDIR /var/www/html/web


RUN composer update -vvv -o && \
    bower update && \
    php app/console assets:install web --symlink && \
    php app/console assetic:dump && \
    php app/console doctrine:schema:drop --force && \
    php app/console doctrine:schema:create && \
    php app/console ojs:install && \
    php app/console ojs:install:samples

CMD php-fpm
