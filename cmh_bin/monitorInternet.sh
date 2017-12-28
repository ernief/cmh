#!/bin/bash
INTERNET_LOG_FILE=/home/homeseer/logs/internetDown.log
INTERVAL="60s"
COUNTER=0
echo "`date`	$COUNTER	internet working - monitoring every $INTERVAL" >> $INTERNET_LOG_FILE

# just in case we start out with the internet not working ...
sleep $INTERVAL

while [ 1 ]
do
	ping -q -c 1 -W 2 8.8.8.8 >/dev/null
	if [ $? -ne 0 ]
	then
		let COUNTER=COUNTER+1
		echo "`date`	$COUNTER	vvv internet down" >> $INTERNET_LOG_FILE
	else
		if [ $COUNTER -gt 0 ]
		then
			COUNTER=0
			echo "`date`	$COUNTER	internet working" >> $INTERNET_LOG_FILE
		fi
	fi
	sleep $INTERVAL
done
