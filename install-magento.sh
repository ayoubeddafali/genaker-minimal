#!/usr/bin/env bash


DB_HOST="mysql.cl8my0a0awfv.us-east-2.rds.amazonaws.com"

## Install PHP 8.2 and its modules
yum -y update
yum remove php*
amazon-linux-extras install -y php8.2
yum install -y php php-common php-mysqlnd php-opcache php-xml php-mcrypt php-gd php-soap php-redis php-bcmath php-intl php-mbstring php-json php-iconv php-fpm php-zip
php -v

## Install Composer

yum install wget unzip
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/bin --filename=composer
composer -v

## Install Nginx
sudo amazon-linux-extras install -y nginx1
nginx -v

## Install helper tools
sudo yum install mysql
sudo amazon-linux-extras install -y redis6

## Configure php-fpm user to be nginx
sed -i '/^user /s/=.*$/= nginx/' /etc/php-fpm.d/www.conf
sed -i '/^group /s/=.*$/= nginx/' /etc/php-fpm.d/www.conf
service php-fpm restart

## Install Magento
mkdir -p /var/www/html/magento
cd /var/www/html/magento
wget https://github.com/OpenMage/magento-lts/releases/download/v20.5.0/openmage-v20.5.0.zip
unzip openmage-v20.5.0.zip
rm -rf openmage-v20.5.0.zip


## Configure Nginx

#!/bin/bash
#### Install nginx configuration
#### IT WILL REMOVE ALL CONFIGURATION FILES THAT HAVE BEEN PREVIOUSLY INSTALLED.

NGINX_EXTRA_CONF="error_page.conf extra_protect.conf export.conf php_backend.conf maintenance.conf maps.conf phpmyadmin.conf"
NGINX_EXTRA_CONF_URL="https://raw.githubusercontent.com/magenx/nginx-config/master/magento1/conf_m1/"

echo "---> CREATING NGINX CONFIGURATION FILES NOW"
echo

MY_DOMAIN="_"
MY_SHOP_PATH="/var/www/html/magento"

wget -qO /etc/nginx/fastcgi_params https://raw.githubusercontent.com/magenx/nginx-config/master/magento1/fastcgi_params
wget -qO /etc/nginx/nginx.conf https://raw.githubusercontent.com/magenx/nginx-config/master/magento1/nginx.conf

sed -i "s/www/sites-enabled/g" /etc/nginx/nginx.conf

mkdir -p /etc/nginx/sites-enabled
mkdir -p /etc/nginx/sites-available && cd $_
wget -q https://raw.githubusercontent.com/magenx/nginx-config/master/magento1/sites-available/default.conf
wget -q https://raw.githubusercontent.com/magenx/nginx-config/master/magento1/sites-available/magento1.conf

sed -i "s/example.com/${MY_DOMAIN}/g" /etc/nginx/sites-available/magento1.conf
sed -i "s,root /var/www/html,root ${MY_SHOP_PATH},g" /etc/nginx/sites-available/magento1.conf

ln -s /etc/nginx/sites-available/magento1.conf /etc/nginx/sites-enabled/magento1.conf
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

mkdir -p /etc/nginx/conf_m1 && cd /etc/nginx/conf_m1/
for CONFIG in ${NGINX_EXTRA_CONF}
do
wget -q ${NGINX_EXTRA_CONF_URL}${CONFIG}
done

rm -rf /etc/nginx/sites-enabled/default.conf
rm -rf /etc/nginx/sites-available/default.conf

sed -i  's/127.0.0.1:${MAGE_ROUTE}/unix:\/var\/run\/php-fpm\/www.sock/g' /etc/nginx/conf_m1/php_backend.conf 



## Install sample data

cd /tmp
wget https://github.com/Vinai/compressed-magento-sample-data/raw/b1740ffe864198e31cef1a610047eaa8f3de293c/compressed-no-mp3-magento-sample-data-1.9.2.4.tgz
tar -xzf compressed-no-mp3-magento-sample-data-1.9.2.4.tgz

cd /var/www/html/magento/media
yes | cp -Rf /tmp/magento-sample-data-1.9.2.4/media/* .

cd /var/www/html/magento/skin
yes | cp -Rf /tmp/magento-sample-data-1.9.2.4/skin/* .

mysqladmin -h "${DB_HOST}" -u collie --password="CPqBueCwW6n7" create magento;

mysql -h "${DB_HOST}" -u collie --password="CPqBueCwW6n7" magento <  /tmp/magento-sample-data-1.9.2.4/magento_sample_data_for_1.9.2.4.sql

## Set permissions

chown -R nginx:nginx /var/www/html/magento
cd /var/www/html/magento
find . -type d -exec chmod 700 {} +
find . -type f -exec chmod 600 {} +

## Restart Services
service php-fpm restart
nginx -t 
service nginx restart
