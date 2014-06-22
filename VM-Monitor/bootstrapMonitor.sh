#!/usr/bin/env bash

# Setup HOSTS
echo "127.0.0.1		monitor" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts
echo "192.168.100.10	web" >> /etc/hosts

#Install mailx
yum install -y mailx

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