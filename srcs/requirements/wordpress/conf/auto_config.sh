#!/bin/bash
set -eo pipefail

# Wait for MariaDB with timeout
wait_for_db() {
    local timeout=60
    local count=0
    
    echo "Waiting for MariaDB to be ready..."
    while ! mysqladmin ping -h"mariadb" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
        count=$((count+1))
        if [ $count -ge $timeout ]; then
            echo "ERROR: MariaDB connection timed out after $timeout seconds"
            exit 1
        fi
        sleep 1
    done
    echo "MariaDB is ready!"
}

configure_wordpress() {
    # Create wp-config.php if it doesn't exist
    if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
        wp config create --allow-root \
            --dbname=${MYSQL_DATABASE} \
            --dbuser=${MYSQL_USER} \
            --dbpass=${MYSQL_PASSWORD} \
            --dbhost=mariadb \
            --dbcharset=utf8mb4 \
            --dbcollate=utf8mb4_unicode_ci \
            --path='/var/www/wordpress'
    fi

    # Install WordPress if not installed
    if ! wp core is-installed --allow-root; then
        wp core install --url=${DOMAIN_NAME} \
            --title="${SITE_TITLE:-My WordPress Site}" \
            --admin_user=${ADMIN_USER:-admin} \
            --admin_password=${ADMIN_PASSWORD:-securepassword} \
            --admin_email=${ADMIN_EMAIL:-admin@example.com} \
            --skip-email \
            --allow-root
    fi

    # Set proper permissions
    chown -R www-data:www-data /var/www/wordpress
    find /var/www/wordpress -type d -exec chmod 755 {} \;
    find /var/www/wordpress -type f -exec chmod 644 {} \;
    chmod 600 /var/www/wordpress/wp-config.php
}

# Main execution
wait_for_db
configure_wordpress

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec php-fpm7.3 -F