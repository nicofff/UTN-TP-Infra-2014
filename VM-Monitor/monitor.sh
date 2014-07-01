#!/bin/bash 


#LOG=/tmp/monitor.log
source ./config/conf/monitorConfig.sh

#Cargo funciones de mail.
source ./config/conf/mail.sh


echo "Iniciando Monitoreo"
echo "SECONDS =" $SECONDS
echo "ATTEMPTS =" $ATTEMPTS
echo "WEB_HOST =" $WEB_HOST 

while :
do

#! Toma la salida del ping. Si la misma figura "icmp" la cantidad de lineas sera 1. 
ping -c $ATTEMPTS $WEB_HOST > /dev/null

if [ $? -eq 0 ]
then
#	echo "Host UP! $(date +%H%M%S)" > $LOG
        echo "Host UP!"  
else 
#	echo "Host DOWN! $( date +%H%M%S)" > $LOG
        echo "Host DOWN!"
		sendErrorMail
fi

sleep $SECONDS 

done
