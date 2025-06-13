FROM debian:buster

# Create necessary directories and set permissions
RUN mkdir -p /run/php && \
    chown www-data:www-data /run/php && \
    mkdir -p /var/www/wordpress && \
    chown -R www-data:www-data /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    php7.3 \
    php-fpm \
    php-mysql \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download and extract WordPress to the correct location
RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /tmp && \
    tar -xzf /tmp/wordpress-6.0-fr_FR.tar.gz -C /var/www/wordpress --strip-components=1 && \
    rm /tmp/wordpress-6.0-fr_FR.tar.gz

# Configure PHP-FPM
COPY conf/wordpress.conf /usr/local/etc/php-fpm.d/wordpress.conf

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy and prepare auto-config script
COPY conf/auto_config.sh /usr/local/bin/auto_config.sh
RUN chmod +x /usr/local/bin/auto_config.sh

# Set the working directory
WORKDIR /var/www/wordpress

CMD ["php-fpm7.3", "-F"]