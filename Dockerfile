FROM php:8.2-fpm

# ------------------------------------------------------------
# Install system dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Install NodeJS (Node 18)
# ------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# ------------------------------------------------------------
# Configure & Install PHP Extensions
# ------------------------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip bcmath mbstring

# ------------------------------------------------------------
# Install Composer
# ------------------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ------------------------------------------------------------
# Copy project
# ------------------------------------------------------------
COPY . .

# ------------------------------------------------------------
# Install PHP dependencies
# ------------------------------------------------------------
RUN composer install --no-dev --optimize-autoloader

# ------------------------------------------------------------
# Install JS dependencies & build assets
# ------------------------------------------------------------
RUN npm install && npm run build

# ------------------------------------------------------------
# Permissions
# ------------------------------------------------------------
RUN chown -R www-data:www-data /var/www/html

CMD ["php-fpm"]
