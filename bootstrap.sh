#!/usr/bin/env bash

apt-get update
debconf-set-selections <<< 'mysql-server mysql-server/root_password password InfraYVirt'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password InfraYVirt'
apt-get install -y git apache2 apache2-mpm-prefork apache2-utils apache2.2-common libapache2-mod-php5 libapr1 libaprutil1 libdbd-mysql-perl libdbi-perl libnet-daemon-perl libplrpc-perl libpq5 mysql-client-5.5 mysql-common mysql-server mysql-server-5.5 php5-common php5-mysql php5-mysqlnd php5-mcrypt

rm /var/www/index.html
git clone  https://github.com/nicofff/inscripciones.git /var/www
# service mysql start # Starts automatically
service apache2 start
mysql -u root -pInfraYVirt -e "CREATE DATABASE inscripciones;"
mysql -u root -pInfraYVirt inscripciones < /var/www/dump.sql


