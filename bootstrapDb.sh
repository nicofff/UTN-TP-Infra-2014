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
until gluster peer probe web
do
	echo "waiting for gluster to come up in db Web Server";
	sleep 5;
done

gluster volume create dbstorage replica 2 web:/data db:/data force #Configuro que la data se replique entre los 2 servers
gluster volume start dbstorage
mkdir /mnt/mysql
mount.glusterfs db:/dbstorage /mnt/mysql # Monto mi storage replicado en /mnt/mysql (que esta seteado como datadir de mysql en el my.cnf)

# Set up LAMP
yum install httpd mysql mysql-server php php-common php-devel php-cli php-mysql php-mcrypt git nano -y
cp /vagrant/config/my.cnf /etc/my.cnf
service mysqld start
mysqladmin -u root password InfraYVirt

git clone  https://github.com/nicofff/inscripciones.git /var/www/html

mysql -u root -pInfraYVirt -e "CREATE DATABASE inscripciones;"
mysql -u root -pInfraYVirt -e "GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'%' identified by 'inscripciones'; GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'localhost' identified by 'inscripciones'; FLUSH PRIVILEGES;" # Crear usuario con acceso desde cualquier lado
mysql -u root -pInfraYVirt inscripciones < /var/www/html/dump.sql


