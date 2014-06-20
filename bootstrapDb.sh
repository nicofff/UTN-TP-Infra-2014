#!/usr/bin/env bash

echo "*********** Initiating Db VM"

source /vagrant/bootstrapCommons.sh

# Setup HOSTS
echo "192.168.100.10 	web" >> /etc/hosts
echo "127.0.0.1	db" >> /etc/hosts


gluster volume create dbstorage replica 2 web:/data db:/data force # Setup Data replication between the 2 nodes
gluster volume start dbstorage
#mkdir /mnt/mysql
#mount.glusterfs db:/dbstorage /mnt/mysql # /mnt/mysql is set up as the datadir, both in my.cnf and in the cluster resource definition
#echo "db:/dbstorage /mnt/mysql glusterfs defaults,_netdev 0 0" >> /etc/fstab

chkconfig --levels 235 glusterd on # Start glusterd on boot

# Copy Config files

cp /vagrant/config/my.cnf /etc/my.cnf
cp /vagrant/config/corosync.conf /etc/corosync/
cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf 
cp /vagrant/config/mysql /usr/lib/ocf/resource.d/heartbeat/mysql # Mysql monitoring script. Default one doesn't work

# Checkout App
git clone  https://github.com/nicofff/inscripciones.git /var/www/html

# Set up Mysql
service mysqld start
mysqladmin -u root password InfraYVirt # Set root password
mysql -u root -pInfraYVirt -e "CREATE DATABASE inscripciones;"
mysql -u root -pInfraYVirt -e "GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'%' identified by 'inscripciones'; GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'localhost' identified by 'inscripciones'; FLUSH PRIVILEGES;" # Create user, give access from anywhare
mysql -u root -pInfraYVirt inscripciones < /var/www/html/dump.sql # Import database dump

service mysqld stop # Stop Mysql, managed by cluster

# Setup Cluster Management. Common

service corosync start
service pacemaker start

# Setup Cluster Management. Cluster Config

until crm status | grep Online |grep web
do
	echo "*********** Waiting for web to join the cluter";
	sleep 5;
done

crm configure property stonith-enabled=false
crm configure property no-quorum-policy=ignore
crm configure primitive ClusterIP ocf:heartbeat:IPaddr2 params ip=192.168.1.205 cidr_netmask=24 op monitor interval=30s
crm configure primitive gluster-share  Filesystem params device="localhost:/dbstorage" directory="/mnt/mysql" fstype=glusterfs
crm configure clone gluster-share-clone gluster-share meta interleave=true
crm configure primitive WebSite ocf:heartbeat:apache params configfile=/etc/httpd/conf/httpd.conf op monitor interval=1min
crm configure colocation website-with-ip INFINITY: WebSite ClusterIP
crm configure order apache-after-ip mandatory: ClusterIP WebSite
crm configure primitive MySQL ocf:heartbeat:mysql params config=/etc/my.cnf datadir=/mnt/mysql test_passwd=InfraYVirt op monitor interval="30s" op start timeout="120s" op stop timeout="120s"
#crm configure order gluster-before-mysql mandatory: gluster-share-clone MySQL
crm configure location prefer-db-MySQL MySQL 50: db
crm configure location prefer-web-WebSite WebSite 50: web

chkconfig corosync on
chkconfig pacemaker on