#!/bin/bash
# script to send simple email 
# email subject
export SUBJECT="Warning! Your host is Down - IVSolutions"
# Email text/message
export EMAILMESSAGE="Host Down!"
#### SMTP - CONFIGURATION ####
export TO=cheppi74@gmail.com

# send an email using mailx

function sendErrorMail(){

echo "$EMAILMESSAGE" | mailx -v -s "$SUBJECT" "$TO"
}

