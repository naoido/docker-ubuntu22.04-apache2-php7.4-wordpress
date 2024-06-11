FROM wordpress:php7.4-apache AS wordpress

FROM ubuntu/apache2:2.4-22.04_beta

WORKDIR /usr/local/src

RUN apt-get update \
    && apt-get install -y \
    php \
    php-mysql \
    git \
    zip \
    unzip \
    vim \
    wget

RUN apt-get install -y \
    libargon2-1 \
    libargon2-dev \
    libonig5 \
    libwebp-dev \
    libicu-dev


RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb \
    && dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb

COPY --from=wordpress /usr/local/bin/php /usr/local/bin/
COPY --from=wordpress /usr/local/etc/php /usr/local/etc/php
COPY --from=wordpress /usr/local/lib/php /usr/local/lib/php

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
RUN a2enconf fqdn
RUN a2enmod rewrite

RUN . /etc/apache2/envvars

CMD ["apache2ctl", "-D", "FOREGROUND"]
