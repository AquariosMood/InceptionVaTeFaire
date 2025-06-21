FROM debian:buster

# Set environment variables
ENV WORDPRESS_VERSION=6.0 \
    WORDPRESS_LOCALE=fr_FR \
    PHP_VERSION=7.3

# Create necessary directories
RUN mkdir -p /run/php /var/www/wordpress && \
    chown -R www-data:www-data /run/php /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    php${PHP_VERSION} \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-xmlrpc \
    php-soap \
    php-intl \
    php-zip \
    php-opcache \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download and extract WordPress
RUN wget https://${WORDPRESS_LOCALE}.wordpress.org/wordpress-${WORDPRESS_VERSION}-${WORDPRESS_LOCALE}.tar.gz -P /tmp && \
    tar -xzf /tmp/wordpress-${WORDPRESS_VERSION}-${WORDPRESS_LOCALE}.tar.gz -C /var/www/wordpress --strip-components=1 && \
    rm /tmp/wordpress-${WORDPRESS_VERSION}-${WORDPRESS_LOCALE}.tar.gz

# Install WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# Copy configuration files
COPY conf/wordpress.conf /etc/php/${PHP_VERSION}/fpm/pool.d/wordpress.conf
COPY conf/auto_config.sh /usr/local/bin/auto_config.sh
RUN chmod +x /usr/local/bin/auto_config.sh

# Set permissions
RUN chown -R www-data:www-data /var/www/wordpress && \
    find /var/www/wordpress -type d -exec chmod 755 {} \; && \
    find /var/www/wordpress -type f -exec chmod 644 {} \;

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:9000/ping || exit 1

WORKDIR /var/www/wordpress

ENTRYPOINT ["/usr/local/bin/auto_config.sh"]
CMD ["php-fpm7.3", "-F"]