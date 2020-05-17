#!/bin/bash
set -e

# VARIABLES
#=====================#
user=yq94
group=yq
baseDir=/usr/local
dataDir=/data
logDir=/data/logs
#=====================#

# check_usage
if [ $# -ne 2 ]; then
	echo "Usage: $0  PKG  PORT"
	exit 1
fi

# create directory
mkdir -p ${baseDir}/redis${R_PORT}/conf
mkdir -p ${logDir}/redis${R_PORT}
mkdir -p ${dataDir}/redis${R_PORT}

# compile and install
R_PORT=$2
fileName=$(tar -tf $1 | head -1 | cut -d/ -f1)
tar -zxf ./$1
cd ${fileName}
make PREFIX=${baseDir}/redis${R_PORT} install

# config file
echo -e "port ${R_PORT}
daemonize yes
bind 0.0.0.0
requirepass qwer@1234
loglevel warning
logfile \"${logDir}/redis${R_PORT}/redis${R_PORT}.log\"
dir \"${dataDir}/redis${R_PORT}\"
dbfilename \"dump${R_PORT}.rdb\"
save 900 1
save 300 10
save 60 10000" >${baseDir}/redis${R_PORT}/conf/redis${R_PORT}.conf
echo "Installed Successfully.
run: ${baseDir}/redis${R_PORT}/bin/redis-server ${FF}/redis${R_PORT}/conf/redis${R_PORT}.conf"
