#!/usr/bin/expect -f

spawn scp /home/vagrant/inscripciones.sql vagrant@192.168.100.13:/home/vagrant

expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "vagrant\r"
  }
}
interact