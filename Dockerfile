# Multi-stage build, see https://docs.docker.com/develop/develop-images/multistage-build/
FROM alpine AS builder

ENV VERSION 0.9.4

ADD https://github.com/sabre-io/Baikal/releases/download/${VERSION}/baikal-${VERSION}.zip .
RUN apk add unzip && unzip -q baikal-${VERSION}.zip

# Final Docker image
FROM php:8.2-apache

# Install Baikal and required dependencies
COPY --from=builder --chown=www-data:www-data baikal /var/www/baikal
RUN apt-get update            &&\
    apt-get install -y          \
    libcurl4-openssl-dev      \
    msmtp msmtp-mta           &&\
    rm -rf /var/lib/apt/lists/* &&\
    docker-php-ext-install curl pdo pdo_mysql

# Configure Apache + HTTPS
COPY apache.conf /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod rewrite

# Expose HTTPS & data directory
EXPOSE 80
VOLUME /var/www/baikal/config
VOLUME /var/www/baikal/Specific

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER www-data:www-data
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD  [ "apache2-foreground" ]
