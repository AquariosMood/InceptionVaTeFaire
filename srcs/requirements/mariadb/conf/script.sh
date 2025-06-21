#!/bin/bash
set -eo pipefail

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
        SET @@SESSION.SQL_LOG_BIN=0;
        
        -- Remove anonymous users
        DELETE FROM mysql.user WHERE User='';
        
        -- Remove test database
        DROP DATABASE IF EXISTS test;
        
        -- Create application database
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        
        -- Create application user with full access
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        
        -- Create root user with remote access
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
        CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
        
        FLUSH PRIVILEGES;
EOSQL
    
    # Shutdown temporary server
    mysqladmin -uroot -S /var/run/mysqld/mysqld.sock -p${MYSQL_ROOT_PASSWORD} shutdown
    
    echo "MariaDB initialization complete"
fi

exec mysqld --user=mysql --skip-name-resolve --bind-address=0.0.0.0