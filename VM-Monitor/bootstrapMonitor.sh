#!/usr/bin/env bash

# Setup HOSTS
echo "127.0.0.1		monitor" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts
echo "192.168.100.10	web" >> /etc/hosts

#Install mailx
yum install -y mailx mysql mysql-server

service mysqld start
mysqladmin -u root password InfraYVirt # Set root password
mysql -u root -pInfraYVirt -e "CREATE DATABASE monitor;"
mysql -u root -pInfraYVirt -e "GRANT ALL PRIVILEGES on monitor.* to 'monitor'@'%' identified by 'monitor'; GRANT ALL PRIVILEGES on monitor.* to 'monitor'@'localhost' identified by 'monitor'; FLUSH PRIVILEGES;" # Create user, give access from anywhare
mysql -u root -pInfraYVirt monitor < /vagrant/config/monitor.sql 

#Copy the config
# * mail.sh: Lib para enviar mails usando Gmail SMTP 
# * monitorConfig
cp -r /vagrant/config/conf/ /home/vagrant/config/

# Copy Certs: contiene los certificados Gmail para enviar mail.
cp -r /vagrant/config/certs/ /home/vagrant/config/

#Copy monitor script
cp /vagrant/monitor.sh /home/vagrant/

#Copy smtp config
cp /vagrant/config/etc/mail.rc /etc/

cp /vagrant/config/app/{main.pl,serviceChecker.pl} /root/

perl /root/main.pl &