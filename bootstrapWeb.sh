#!/usr/bin/env bash

#Setup Gluster repository
cd /etc/yum.repos.d/
wget http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.0/EPEL.repo/glusterfs-epel.repo

echo "127.0.0.1 	web" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts

# Set Up Gluster
yum install glusterfs glusterfs-fuse glusterfs-rdma glusterfs-server -y
service glusterd start
until gluster peer probe db
do
	echo "waiting for gluster to come up in db Server";
	sleep 10;
done
sleep 10
mkdir /mnt/mysql
mount.glusterfs web:/dbstorage /mnt/mysql

cp /vagrant/config/my.cnf /etc/my.cnf
yum install httpd mysql mysql-server php php-common php-devel php-cli php-mysql php-mcrypt git -y

git clone  https://github.com/nicofff/inscripciones.git /var/www/html
service httpd start
