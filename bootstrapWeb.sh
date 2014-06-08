#!/usr/bin/env bash

# Setup Extra repositories
cd /etc/yum.repos.d/
wget http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.0/EPEL.repo/glusterfs-epel.repo
wget http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/network:ha-clustering:Stable.repo

# Setup HOSTS
echo "127.0.0.1 	web" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts

# Intall Gluster, LAMP, Cluster Management, NTP
yum install glusterfs glusterfs-fuse glusterfs-rdma glusterfs-server \
	httpd mysql mysql-server php php-common php-devel php-cli php-mysql php-mcrypt \
	git nano ntp ntpdate \
	pacemaker corosync crmsh -y

# Start NTP
service ntpd start
chkconfig ntpd on

# Setup Gluster
service glusterd start
until gluster peer probe db
do
	echo "waiting for gluster to come up in db Server";
	sleep 10;
done

sleep 10 # Wait for configuration to end on the other node (TODO: do this better)
#mkdir /mnt/mysql
#mount.glusterfs web:/dbstorage /mnt/mysql
#echo "web:/dbstorage /mnt/mysql glusterfs defaults,_netdev 0 0" >> /etc/fstab

chkconfig --levels 235 glusterd on

# Copy Config files

cp /vagrant/config/my.cnf /etc/my.cnf
cp /vagrant/config/corosync.conf /etc/corosync/
cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf 
cp /vagrant/config/mysql /usr/lib/ocf/resource.d/heartbeat/mysql # Mysql monitoring script. Default One doesn't work

# Checkout App
git clone  https://github.com/nicofff/inscripciones.git /var/www/html


# Setup Cluster Management. Common

service corosync start
service pacemaker start
chkconfig corosync on
chkconfig pacemaker on