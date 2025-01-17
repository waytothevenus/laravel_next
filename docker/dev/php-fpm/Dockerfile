FROM php:8.2-fpm AS prod

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    libgmp-dev \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    libzip-dev \
    git \
    curl \
    libonig-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install redis \
 && docker-php-ext-enable redis

RUN docker-php-ext-configure exif

# Install extensions
RUN docker-php-ext-install pdo_mysql gmp mbstring zip exif pcntl opcache
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd exif gmp
RUN docker-php-ext-enable exif


# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]

# Stage: dev
FROM prod AS dev
USER root

RUN apt-get update && pecl install xdebug \
    && docker-php-ext-enable xdebug

USER www