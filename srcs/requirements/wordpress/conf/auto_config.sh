sleep 10


wp config create	--allow-root \
                    --dbname=$SQL_DATABASE \
					--dbuser=$SQL_USER \
					--dbpass=$SQL_PASSWORD \
					--dbhost=mariadb:3306 --path='/var/www/wordpress'

wp core install --url=$DOMAIN --title="$SITE_TITLE" \
    --admin_user=$ADMIN_USER --admin_password=$ADMIN_PASSWORD \
    --admin_email=$ADMIN_EMAIL --skip-email --allow-root