#!/usr/bin/env bash

#Setup Gluster repository
cd /etc/yum.repos.d/
wget http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.0/EPEL.repo/glusterfs-epel.repo

# Set Up HOSTS
echo "192.168.100.10 	web" >> /etc/hosts
echo "127.0.0.1	db" >> /etc/hosts

# Set Up Gluster
yum install glusterfs glusterfs-fuse glusterfs-rdma glusterfs-server -y
service glusterd start
gluster peer probe web
gluster volume create dbstorage replica 2 web:/data db:/data force #Configuro que la data se replique entre los 2 servers
gluster volume start dbstorage
mkdir /mnt/mysql
mount.glusterfs db:/dbstorage /mnt/mysql # Monto mi storage replicado en /mnt/mysql (que esta seteado como datadir de mysql en el my.cnf)

# Set up LAMP
cp /vagrant/config/my.cnf /etc/my.cnf
yum install httpd mysql mysql-server php php-common php-devel php-cli php-mysql php-mcrypt git -y
service mysqld start
mysqladmin -u root password InfraYVirt

git clone  https://github.com/nicofff/inscripciones.git /var/www/html

mysql -u root -pInfraYVirt -e "CREATE DATABASE inscripciones;"
mysql -u root -pInfraYVirt inscripciones < /var/www/html/dump.sql


