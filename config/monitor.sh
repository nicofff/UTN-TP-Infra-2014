#!/bin/bash 

LOG=/tmp/monitor.log
SECONDS=30
ATTEMPTS=1
WEB_HOST="192.168.100.10"

echo "Iniciando Monitoreo"
echo "SECONDS =" $SECONDS
echo "ATTEMPTS =" $ATTEMPTS
echo "WEB_HOST =" $WEB_HOST 

while :
do


#! Toma la salida del ping. Si la misma figura "icmp" la cantidad de lineas sera 1. 
ping -c $ATTEMPTS $WEB_HOST 

if [ $? -eq 0 ]
then
	echo "Host UP! $(date +%H%M%S)" > $LOG
        echo "Host UP!"  
else 
	echo "Host DOWN! $( date +%H%M%S)" > $LOG
        echo "Host DOWN!"
fi

sleep $SECONDS 

done
