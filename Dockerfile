FROM debian:jessie
MAINTAINER OkulBilişim (okulbilisim.com) "info@okulbilisim.com"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* && curl -O http://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg
RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list

# openJDK 1.8 Elastic
RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

ENV LANG C.UTF-8

ENV JAVA_VERSION 8u45
ENV JAVA_DEBIAN_VERSION 8u45-b14-2~bpo8+2

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
		openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
		ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb http://packages.elastic.co/elasticsearch/1.6/debian stable main" >> /etc/apt/sources.list


RUN apt-get update && apt-get install -y git nginx php5-fpm php5-mysqlnd php5-redis php5-cli mysql-server redis-server supervisor php5-dev php-pear elasticsearch && rm -rf /var/lib/apt/lists/*



RUN sed -e 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' -i /etc/php5/cli/php.ini
RUN sed -e 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' -i /etc/php5/fpm/php.ini
RUN sed -e 's/;date\.timezone =/date.timezone = \"UTC\"/' -i /etc/php5/cli/php.ini
RUN sed -e 's/;date\.timezone =/date.timezone = \"UTC\"/' -i /etc/php5/fpm/php.ini
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf
RUN sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/pm\.max_children = 5/pm.max_children = 16/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/pm\.start_servers = 2/pm.start_servers = 6/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/pm\.min_spare_servers = 1/pm.min_spare_servers = 3/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/pm\.max_spare_servers = 3/pm.max_spare_servers = 11/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/;pm\.max_requests = 500/pm.max_requests = 500/' -i /etc/php5/fpm/pool.d/www.conf
RUN echo "memory_limit=1024M" > /etc/php5/cli/conf.d/memory-limit.ini
RUN sed -e 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' -i /etc/mysql/my.cnf
RUN sed -e 's/:33:33:/:1000:1000:/' -i /etc/passwd
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf



ENV COMPOSER_HOME /root/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -O https://phar.phpunit.de/phpunit.phar && chmod +x phpunit.phar && mv phpunit.phar /usr/local/bin/phpunit

RUN echo '#!/bin/bash' > /usr/local/bin/dev && echo 'php /srv/app/console --env=dev $@' >> /usr/local/bin/dev && chmod +x /usr/local/bin/dev
RUN echo '#!/bin/bash' > /usr/local/bin/prod && echo 'php /srv/app/console --env=prod $@' >> /usr/local/bin/prod && chmod +x /usr/local/bin/prod

RUN echo 'shell /bin/bash' > ~/.screenrc

ADD vhost.conf /etc/nginx/sites-available/default
ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD mysql.sh /usr/local/bin/mysql.sh
RUN chmod +x /usr/local/bin/mysql.sh
ADD init.sh /init.sh

EXPOSE 80 3306 9200 9300

VOLUME ["/srv"]
WORKDIR /srv

CMD ["/usr/bin/supervisord"]