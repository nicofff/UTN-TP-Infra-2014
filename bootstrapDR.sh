
echo "127.0.0.1 	web" >> /etc/hosts
echo "127.0.0.1 	db" >> /etc/hosts

yum install httpd mysql mysql-server -y
yum install php php-common php-devel php-cli php-mysql php-mcrypt git nano ntp ntpdate git -y

cp /vagrant/config/httpd.conf /etc/httpd/conf/httpd.conf


echo "***********Checking out web app"
git clone https://github.com/nicofff/inscripciones.git /var/www/html
service httpd start

echo "***********Initiating DB inscripciones..."
service mysqld start
mysqladmin -u root password InfraYVirt # Set root password
mysql -u root -pInfraYVirt -e "CREATE DATABASE inscripciones;"
mysql -u root -pInfraYVirt -e "GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'%' identified by 'inscripciones'; GRANT ALL PRIVILEGES on inscripciones.* to 'inscripciones'@'localhost' identified by 'inscripciones'; FLUSH PRIVILEGES;" # Create user, give access from anywhare
mysql -u root -pInfraYVirt inscripciones < /var/www/html/dump.sql # Import database dump


 ifconfig eth0:1  inet  192.168.1.205  netmask  255.255.255.0

 chkconfig httpd on
 chkconfig mysqld on
