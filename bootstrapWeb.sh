#!/usr/bin/env bash

echo "***********Initiating Web VM"

# Setup HOSTS
echo "127.0.0.1 	web" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts

source /vagrant/bootstrapCommons.sh

echo "***********Initiating Apache"
service httpd start

echo "***********Web VM bootstrap finished"

#echo "***********Sleeping 10 seconds"
#sleep 10 # Wait for configuration to end on the other node (TODO: do this better)
#mkdir /mnt/mysql
#mount.glusterfs web:/dbstorage /mnt/mysql
#echo "web:/dbstorage /mnt/mysql glusterfs defaults,_netdev 0 0" >> /etc/fstab
