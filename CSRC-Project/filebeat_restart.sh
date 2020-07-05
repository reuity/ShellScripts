#!/bin/bash

KEY=filebeat
if [ -z $KEY ]; then
	echo "no process key words specified!"
	echo "Usage: $0 process_key_words"
	exit 1
fi

start_filebeat() {
	echo "Starting..."
	cd /usr/local/filebeat-6.8.8-linux-x86_64
	nohup ./filebeat -e -c filebeat.yml >> /data/logs/go/filebeat/filebeat.log 2>&1 &
    echo "start successful"
}

PID=$(ps -ef | grep $KEY | grep -v $0 | grep -v grep | awk '{print $2}')
if [ -z $PID ]; then
	echo "Process does not exist"
	start_filebeat
else
	echo "killing..."
	kill -9 $PID
	sleep 1
	PID=$(ps -ef | grep $KEY | grep -v $0 | grep -v grep | awk '{print $2}')
	if [ -z $PID ]; then
		echo "kill successful"
		start_filebeat
	else
		echo "kill failed"
		exit 1
	fi
fi