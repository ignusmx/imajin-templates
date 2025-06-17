# Use the official Laravel Sail image which comes with PHP 8.3, Composer, and Node.js
FROM laravelsail/php83-composer:latest

# Set working directory
WORKDIR /var/www

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Create a fresh Laravel project in a temporary directory
RUN composer create-project laravel/laravel /tmp/laravel-app --prefer-dist --no-interaction

# Move the Laravel project to the working directory
RUN mv /tmp/laravel-app/* /tmp/laravel-app/.* /var/www/ 2>/dev/null || true

# Copy template files over the Laravel project (this will override default files)
COPY --chown=www-data:www-data . .

# Install any additional dependencies from our template
RUN composer update --no-interaction --prefer-dist --optimize-autoloader

# Install Node.js dependencies and build assets
RUN npm install && npm run build

# Expose port 8000 for Laravel development server
EXPOSE 8000

# Start PHP development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"] 