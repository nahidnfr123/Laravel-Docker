FROM php:8.2 as php

RUN apt-get update -y
RUN apt-get install -y libpq-dev libcurl4-gnutls-dev \
    git \
    curl \
    nginx \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    -y mariadb-client

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#RUN docker-php-ext-install pdo pdo_mysql bcmath
# Install PHP extensions
RUN docker-php-ext-install zip mysqli pdo pdo_mysql mbstring exif pcntl bcmath gd && docker-php-ext-enable mysqli

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

WORKDIR /var/www
COPY . .

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV PORT=8000
ENTRYPOINT [ "docker/entrypoint.sh" ]

# ==============================================================================
#  node
FROM node:18-alpine as node

WORKDIR /var/www
COPY . .

RUN npm install --global cross-env
RUN npm install

VOLUME /var/www/node_modules
