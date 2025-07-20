#!/usr/bin/env bash

set -euo pipefail

sed -i "s/\$config\['index_page'\] = 'index.php';/\$config\['index_page'\] = '';/g" /var/www/html/install/config/config.php
cp htaccess.sample .htaccess

chown -R vscode:www-data /var/www/html/
chmod -R g+rw /var/www/html/application/cache/
chmod -R g+rw /var/www/html/application/config/
chmod -R g+rw /var/www/html/application/logs/
chmod -R g+rw /var/www/html/assets/
chmod -R g+rw /var/www/html/backup/
chmod -R g+rw /var/www/html/updates/
chmod -R g+rw /var/www/html/uploads/
chmod -R g+rw /var/www/html/userdata/
chmod -R g+rw /var/www/html/images/eqsl_card_images/
chmod -R g+rw /var/www/html/install/

touch /etc/cron.d/wavelog
echo "* * * * * curl --silent http://localhost/index.php/cron/run &>/dev/null" >> /etc/cron.d/wavelog
chmod 0644 /etc/cron.d/wavelog
crontab /etc/cron.d/wavelog
mkdir -p /var/log/cron
sed -i 's/^exec /service cron start\n\nexec /' /usr/local/bin/apache2-foreground

echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Basic Xdebug configuration (some options included in the base definition for the container, but we may want to override it at some point)

echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini
echo "xdebug.mode = debug" >> /usr/local/etc/php/conf.d/xdebug.ini
echo "xdebug.start_with_request = yes" >> /usr/local/etc/php/conf.d/xdebug.ini
echo "xdebug.client_port = 9003" >> /usr/local/etc/php/conf.d/xdebug.ini
echo "xdebug.client_host = 127.0.0.1" >> /usr/local/etc/php/conf.d/xdebug.ini
echo "xdebug.idekey = VSCODE" >> /usr/local/etc/php/conf.d/xdebug.ini

echo -e "file_uploads = On\n\
          memory_limit = 256M\n\
          upload_max_filesize = 64M\n\
          post_max_size = 64M\n\
          max_execution_time = 600\n" > /usr/local/etc/php/conf.d/wavelog.ini

a2enmod rewrite
