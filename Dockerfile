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
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Install NodeJS 18 (for Vite)
# ------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# ------------------------------------------------------------
# Install PHP extensions (GD works here)
# ------------------------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql zip bcmath mbstring

# ------------------------------------------------------------
# Composer (from official image)
# ------------------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ------------------------------------------------------------
# Application directory
# ------------------------------------------------------------
WORKDIR /var/www/html

# Copy source
COPY . .

# ------------------------------------------------------------
# Install PHP dependencies
# ------------------------------------------------------------
RUN composer install --no-dev --optimize-autoloader

# ------------------------------------------------------------
# Install Node/Vite dependencies & build assets
# ------------------------------------------------------------
RUN npm install && npm run build

# ------------------------------------------------------------
# Permissions
# ------------------------------------------------------------
RUN chown -R www-data:www-data /var/www/html

CMD ["php-fpm"]
