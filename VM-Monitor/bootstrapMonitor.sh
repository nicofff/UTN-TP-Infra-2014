#!/usr/bin/env bash

# Setup HOSTS
echo "127.0.0.1		monitor" >> /etc/hosts
echo "192.168.100.11	db" >> /etc/hosts
echo "192.168.100.10	web" >> /etc/hosts

# Copy Config files
cp /vagrant/config/monitor.sh /home/vagrant