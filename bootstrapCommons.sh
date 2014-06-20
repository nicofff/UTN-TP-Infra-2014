#!/usr/bin/env bash

# Setup Extra repositories
echo "*********** Downloading software repositories..."
cd /etc/yum.repos.d/
wget http://download.gluster.org/pub/gluster/glusterfs/LATEST/RHEL/glusterfs-epel.repo #Glusterfs
wget http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/network:ha-clustering:Stable.repo #High Availability tools repo

# Intall Gluster, LAMP, Cluster Management, NTP
echo "*********** Installing software..."
yum install glusterfs glusterfs-fuse glusterfs-rdma glusterfs-server httpd mysql mysql-server -y 
yum install php php-common php-devel php-cli php-mysql php-mcrypt git nano ntp ntpdate pacemaker corosync crmsh -y

# Start NTP
echo "*********** Starting ntpd service..."
service ntpd start
chkconfig ntpd on

# Setup Gluster
echo "*********** Starting glusterfs service..."
service glusterd start
until gluster peer probe web
do
	echo "*********** Waiting for gluster to come up in Web Server";
	sleep 5;
done

# Copy Config files
echo "*********** Copying configuration scripts..."
cp /vagrant/config/my.cnf /etc/my.cnf
cp /vagrant/config/corosync.conf /etc/corosync/
cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf 
cp /vagrant/config/mysql /usr/lib/ocf/resource.d/heartbeat/mysql # Mysql monitoring script. Default One doesn't work

