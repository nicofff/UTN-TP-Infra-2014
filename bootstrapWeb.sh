#!/usr/bin/env bash

#Setup Gluster repository
cd /etc/yum.repos.d/
wget http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.0/EPEL.repo/glusterfs-epel.repo
wget http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/network:ha-clustering:Stable.repo

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

yum install httpd mysql mysql-server php php-common php-devel php-cli php-mysql php-mcrypt git nano -y
cp /vagrant/config/my.cnf /etc/my.cnf

git clone  https://github.com/nicofff/inscripciones.git /var/www/html
#service httpd start

# Set up Cluster Management. Common

yum install pacemaker corosync crmsh -y
cp /vagrant/config/corosync.conf /etc/corosync/
cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf 
cd /tmp/
wget --no-check-certificate https://raw.githubusercontent.com/y-trudeau/resource-agents/master/heartbeat/mysql
cp mysql /usr/lib/ocf/resource.d/heartbeat/mysql

service corosync start
service pacemaker start