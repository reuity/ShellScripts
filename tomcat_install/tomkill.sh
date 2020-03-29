#!/bin/bash

KEY=$1
if [ -z $KEY ]; then
	echo "no process key words specified!"
	echo "Usage: $0 process_key_words"
	exit 1
fi

start_tomcat() {
	rm -rf $baseDir/tomcat_$1/work/Catalina/*
	echo "Starting..."
	$baseDir/tomcat_$1/bin/startup.sh
}

PID=$(ps -ef | grep java | grep $KEY | grep -v $0 | grep -v grep | awk '{print $2}')
if [ -z $PID ]; then
	echo "Process does not exist"
	start_tomcat ${KEY}
else
	echo "killing..."
	kill -9 $PID
	sleep 1
	PID=$(ps -ef | grep java | grep $KEY | grep -v $0 | grep -v grep | awk '{print $2}')
	if [ -z $PID ]; then
		echo "killed"
		start_tomcat ${KEY}
	else
		echo "kill failed"
		exit 1
	fi
fi
