FROM php:8.2-fpm

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libgmp-dev \
    zip \
    libzip-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Install and configure PHP extensions
RUN pecl install redis \
    && docker-php-ext-enable redis

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gmp \
        mbstring \
        zip \
        exif \
        pcntl \
        opcache \
        gd

# Copy production PHP configuration
COPY docker/prod/php-fpm/php.ini /usr/local/etc/php/php.ini
COPY docker/prod/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/prod/php-fpm/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Set proper permissions
RUN chown -R www-data:www-data /app

# Switch to non-root user
USER www-data

# Expose port 9000
EXPOSE 9000

CMD ["php-fpm"]