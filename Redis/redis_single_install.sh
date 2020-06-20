#!/bin/bash
set -e -u

# VARIABLES
#=====================#
user=root
group=root
password=qwer@1234   
baseDir=/usr/local
dataDir=/data
logDir=/data/logs
#=====================#

# check_usage
if [ $# -ne 2 ]; then
    echo "Usage: $0  PKG  PORT"
    exit 1
fi

PORT=$2
workDIR=$(dirname $(readlink -f $0))

# create directory
mkdir -p ${baseDir}/redis${PORT}/etc
mkdir -p ${dataDir}/redis${PORT}
mkdir -p ${logDir}/redis

# compile and install
fileName=$(tar -tf $1 | head -1 | cut -d/ -f1)
tar -zxf ./$1
cd ${fileName}
make -j $(nproc) PREFIX=${baseDir}/redis${PORT} install

# config file
\cp -f ${workDIR}/redis.conf ${baseDir}/redis${PORT}/etc/redis${PORT}.conf
sed -i "s/-{PASSWORD}-/${password}/g" ${baseDir}/redis${PORT}/etc/redis${PORT}.conf
sed -i "s/-{PORT}-/${PORT}/g" ${baseDir}/redis${PORT}/etc/redis${PORT}.conf
sed -i "s#-{DATADIR}-#${dataDir}/redis${PORT}#g" ${baseDir}/redis${PORT}/etc/redis${PORT}.conf

# chown directory
chown -R ${user}.${group} ${baseDir}/redis${PORT}
chown -R ${user}.${group} ${dataDir}/redis${PORT}
chown -R ${user}.${group} ${logDir}/redis
echo "Installed Successfully."

# start redis
su - ${user} -c "${baseDir}/redis${PORT}/bin/redis-server ${baseDir}/redis${PORT}/etc/redis${PORT}.conf"
echo "Started."
