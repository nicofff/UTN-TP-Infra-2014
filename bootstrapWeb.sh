#!/usr/bin/env bash

echo "***********Initiating Web VM"

# Setup HOSTS
echo "127.0.0.1 	web" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts

source /vagrant/bootstrapCommons.sh

until service drbd status | grep UpToDate/UpToDate
do 
	sleep 5;
	echo "waiting for drbd to finish syncing";
done

sleep 10

service drbd stop

service corosync start
service pacemaker start
