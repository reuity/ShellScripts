#!/bin/bash
set -e -u

# VARIABLES
#=====================#
user=root
group=root
password=qwer@1234   
BaseDir=/usr/local
DataDir=/data
LogDir=/data/logs
#=====================#

# check_usage
if [ $# -ne 2 ]; then
    echo "Usage: $0  PKG  PORT"
    exit 1
fi

PORT=$2
workDIR=$(dirname $(readlink -f $0))

# create directory
mkdir -p ${BaseDir}/redis${PORT}/etc
mkdir -p ${DataDir}/redis${PORT}
mkdir -p ${LogDir}/redis

# compile and install
fileName=$(tar -tf $1 | head -1 | cut -d/ -f1)
tar -zxf ./$1
cd ${fileName}
make -j $(nproc) PREFIX=${BaseDir}/redis${PORT} install

# config file
\cp -f ${workDIR}/redis.conf ${BaseDir}/redis${PORT}/etc/redis${PORT}.conf
sed -i "s/-{PASSWORD}-/${password}/g" ${BaseDir}/redis${PORT}/etc/redis${PORT}.conf
sed -i "s/-{PORT}-/${PORT}/g" ${BaseDir}/redis${PORT}/etc/redis${PORT}.conf
sed -i "s#-{DATADIR}-#${DataDir}/redis${PORT}#g" ${BaseDir}/redis${PORT}/etc/redis${PORT}.conf

# chown directory
chown -R ${user}.${group} ${BaseDir}/redis${PORT}
chown -R ${user}.${group} ${DataDir}/redis${PORT}
chown -R ${user}.${group} ${LogDir}/redis
echo "Installed Successfully."

# start redis
su - ${user} -c "${BaseDir}/redis${PORT}/bin/redis-server ${BaseDir}/redis${PORT}/etc/redis${PORT}.conf"
echo "Started."
