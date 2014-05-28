#!/usr/bin/env bash

#Setup Gluster repository
cd /etc/yum.repos.d/
wget http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.0/EPEL.repo/glusterfs-epel.repo
wget http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/network:ha-clustering:Stable.repo

# Set Up HOSTS
echo "192.168.100.10 	web" >> /etc/hosts
echo "127.0.0.1	db" >> /etc/hosts

# Set Up Gluster
yum install glusterfs glusterfs-fuse glusterfs-rdma glusterfs-server -y
service glusterd start
until gluster peer probe web
do
	echo "waiting for gluster to come up in Web Server";
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

service mysqld stop

# Set up Cluster Management. Common

yum install pacemaker corosync crmsh -y
cp /vagrant/config/corosync.conf /etc/corosync/
cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf
cd /tmp/
wget --no-check-certificate https://raw.githubusercontent.com/y-trudeau/resource-agents/master/heartbeat/mysql
cp mysql /usr/lib/ocf/resource.d/heartbeat/mysql

service corosync start
service pacemaker start


# Set up Cluster Management. Cluster Config

crm configure property stonith-enabled=false
crm configure property no-quorum-policy=ignore
crm configure primitive ClusterIP ocf:heartbeat:IPaddr2 params ip=192.168.1.205 cidr_netmask=24 op monitor interval=30s
crm configure primitive WebSite ocf:heartbeat:apache params configfile=/etc/httpd/conf/httpd.conf op monitor interval=1min
crm configure colocation website-with-ip INFINITY: WebSite ClusterIP
crm configure order apache-after-ip mandatory: ClusterIP WebSite
crm configure primitive MySQL ocf:heartbeat:mysql params config=/etc/my.cnf datadir=/mnt/mysql test_passwd=InfraYVirt op monitor interval="30s" op start timeout="120s" op stop timeout="120s"
crm configure location prefer-db-MySQL MySQL 50: db
crm configure location prefer-web-WebSite WebSite 50: web