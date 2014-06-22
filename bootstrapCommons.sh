#!/usr/bin/env bash

echo "*********** Downloading other repositories..."
cd /etc/yum.repos.d/
rpm -Uvh ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/centos/5.10/extras/i386/RPMS/xfsprogs-2.9.4-1.el5.centos.i386.rpm
rpm -Uvh http://elrepo.org/elrepo-release-6-5.el6.elrepo.noarch.rpm

echo "*********** Installing software LAMP, Cluster Management, NTP and dependencies..."
yum install httpd mysql mysql-server -y
yum install php php-common php-devel php-cli php-mysql php-mcrypt git nano ntp ntpdate pacemaker corosync pcs -y
yum install drbd84-utils  kmod-drbd84 -y

echo "*********** Copying configuration scripts..."
cp /vagrant/config/my.cnf /etc/my.cnf
cp /vagrant/config/corosync.conf /etc/corosync/
cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf
cp /vagrant/config/drbd/* /etc/drbd.d/
cp /vagrant/config/mysql /usr/lib/ocf/resource.d/heartbeat/mysql # Mysql monitoring script. Default One doesn't work
cp /vagrant/config/selinux-config /etc/selinux/config

echo "***********Checking out web app"
git clone https://github.com/nicofff/inscripciones.git /var/www/html

echo "***********Configuring services to init on start"
chkconfig ntpd on
chkconfig corosync on
chkconfig pacemaker on

echo "***********Disable Firewall"

service iptables stop
chkconfig iptables off
echo 0 >/selinux/enforce

echo "***********Starting services ntpd, corosync & pacemaker"
service ntpd start

echo "***********Starting DRBD"
modprobe drbd
drbdadm create-md mysqldata
service drbd start

mkdir /mnt/mysql
