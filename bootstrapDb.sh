#!/usr/bin/env bash

echo "*********** Initiating Db VM"

source /vagrant/bootstrapCommons.sh

# Setup HOSTS
echo "192.168.100.10 	web" >> /etc/hosts
echo "127.0.0.1	db" >> /etc/hosts

echo "***********Creating DRBD volume"
drbdadm primary --force mysqldata
mkfs.ext3 /dev/drbd0
mount /dev/drbd0 /mnt/mysql/

chmod -R 777 /mnt/mysql
chown -R mysql:mysql /mnt/mysql

echo "***********Initiating DB inscripciones..."
service mysqld start
mysqladmin -u root password InfraYVirt # Set root password
mysql -u root -pInfraYVirt -e "CREATE DATABASE inscripciones;"
mysql -u root -pInfraYVirt -e "GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'%' identified by 'inscripciones'; GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'localhost' identified by 'inscripciones'; FLUSH PRIVILEGES;" # Create user, give access from anywhare
mysql -u root -pInfraYVirt inscripciones < /var/www/html/dump.sql # Import database dump

until service drbd status | grep UpToDate/UpToDate
do 
	sleep 5;
	echo "waiting for drbd to finish syncing";
done

sleep 10

service mysqld stop # Stop Mysql, managed by cluster
umount /mnt/mysql
drbdadm secondary mysqldata
service drbd stop


service corosync start
service pacemaker start


until pcs status | grep Online |grep web
do
	echo "***********Waiting for web to join the cluter";
	sleep 5;
done

echo "***********Configuring crm..."

cd /root
pcs -f "CONFIGFILE" property set stonith-enabled=false
pcs -f "CONFIGFILE" property set start-failure-is-fatal=false

pcs -f "CONFIGFILE" property set no-quorum-policy=ignore

pcs -f "CONFIGFILE" resource create p_drbd_mysql ocf:linbit:drbd drbd_resource=mysqldata op monitor interval=15s # DRBD Resource

pcs -f "CONFIGFILE" resource master ms_drbd_mysql p_drbd_mysql master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify="true" # DRBD master/slave

pcs -f "CONFIGFILE" resource create p_fs_mysql ocf:heartbeat:Filesystem device=/dev/drbd0 directory=/mnt/mysql fstype=ext3 # DRBD Mountpoint

pcs -f "CONFIGFILE" resource create p_mysql ocf:heartbeat:mysql config=/etc/my.cnf datadir=/mnt/mysql test_passwd=InfraYVirt op monitor interval="30s" op start timeout="120s" op stop timeout="120s"

pcs -f "CONFIGFILE" resource group add g_mysql p_fs_mysql p_mysql

pcs -f "CONFIGFILE" constraint colocation add g_mysql with master ms_drbd_mysql INFINITY

pcs -f "CONFIGFILE" constraint order promote ms_drbd_mysql then start g_mysql

pcs -f "CONFIGFILE" resource create ClusterIP ocf:heartbeat:IPaddr2 params ip=192.168.1.205 cidr_netmask=24 op monitor interval=30s
pcs -f "CONFIGFILE" resource create WebSite ocf:heartbeat:apache params configfile=/etc/httpd/conf/httpd.conf op monitor interval=1min
pcs -f "CONFIGFILE" constraint colocation add WebSite ClusterIP INFINITY
pcs -f "CONFIGFILE" constraint order ClusterIP then WebSite

pcs -f "CONFIGFILE" constraint location add prefer-db-MySQL p_mysql db 50
pcs -f "CONFIGFILE" constraint location add prefer-web-WebSite WebSite web 50

pcs cluster cib-push "CONFIGFILE"


echo "***********DB VM bootstrap finished"