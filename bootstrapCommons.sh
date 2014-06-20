#!/usr/bin/env bash

echo "*********** Downloading other repositories..."
cd /etc/yum.repos.d/
wget -nc http://download.gluster.org/pub/gluster/glusterfs/LATEST/RHEL/glusterfs-epel.repo #Glusterfs
wget -nc http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/network:ha-clustering:Stable.repo #High Availability tools repo
wget -nc ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/centos/5.10/extras/i386/RPMS/xfsprogs-2.9.4-1.el5.centos.i386.rpm -P /tmp #Manual dependency install for Pacemaker

echo "*********** Installing software Gluster, LAMP, Cluster Management, NTP and dependencies..."
yum install /tmp/xfsprogs-2.9.4-1.el5.centos.i386.rpm -y 
yum install glusterfs glusterfs-fuse glusterfs-rdma glusterfs-server httpd mysql mysql-server -y
yum install php php-common php-devel php-cli php-mysql php-mcrypt git nano ntp ntpdate pacemaker corosync crmsh -y

echo "*********** Copying configuration scripts..."
cp /vagrant/config/my.cnf /etc/my.cnf
cp /vagrant/config/corosync.conf /etc/corosync/
cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf 
cp /vagrant/config/mysql /usr/lib/ocf/resource.d/heartbeat/mysql # Mysql monitoring script. Default One doesn't work

echo "***********Checking out web app"
git clone  https://github.com/nicofff/inscripciones.git /var/www/html

echo "***********Configuring services to init on start"
chkconfig ntpd on
chkconfig --levels 235 glusterd on
chkconfig corosync on
chkconfig pacemaker on

echo "***********Starting services ntpd, corosync & pacemaker"
service ntpd start
service glusterd start
service corosync start
service pacemaker start