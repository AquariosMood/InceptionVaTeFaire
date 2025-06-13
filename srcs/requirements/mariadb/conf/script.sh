#!/bin/bash
set -eo pipefail

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
    
    # Start temporary server
    mysqld_safe --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    
    # Wait for server to start
    for i in {1..30}; do
        if echo 'SELECT 1' | mysql -uroot -S /var/run/mysqld/mysqld.sock; then
            break
        fi
        sleep 1
    done
    
    # Configure database
    mysql -uroot -S /var/run/mysqld/mysqld.sock <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL
    
    # Shutdown temporary server
    mysqladmin -uroot -S /var/run/mysqld/mysqld.sock -p${MYSQL_ROOT_PASSWORD} shutdown
fi

# Start MariaDB normally
exec mysqld --user=mysql