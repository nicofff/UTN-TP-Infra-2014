#!/usr/bin/env bash

echo "*********** Initiating Web VM"

source /vagrant/bootstrapCommons.sh

# Setup HOSTS
echo "127.0.0.1 	web" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts

sleep 10 # Wait for configuration to end on the other node (TODO: do this better)
#mkdir /mnt/mysql
#mount.glusterfs web:/dbstorage /mnt/mysql
#echo "web:/dbstorage /mnt/mysql glusterfs defaults,_netdev 0 0" >> /etc/fstab

chkconfig --levels 235 glusterd on

# Checkout App
git clone  https://github.com/nicofff/inscripciones.git /var/www/html

# Setup Cluster Management. Common
service corosync start
service pacemaker start
chkconfig corosync on
chkconfig pacemaker on