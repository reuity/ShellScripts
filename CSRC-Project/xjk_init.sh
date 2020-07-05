#!/bin/bash
set -e -u

# create user wls81.wls
groupadd -g 602 wls
mkdir -p /wls
useradd -d /wls/wls81 -s /bin/bash -g 602 -o -u 602 wls81
chown -R wls81.wls /wls/wls81
chmod 755 /wls /wls/wls81

# create user logop.log
groupadd -g 603 log
mkdir -p /wls
useradd -d /wls/logop -s /bin/bash -g 603 -o -u 603 logop
chown -R logop.log /wls/logop
chmod 755 /wls/logop

# create directory
mkdir -p /data/xjk/software /data/logs
chown root.root /data /data/xjk /data/xjk/software /data/logs
chmod 755 /data /data/xjk /data/xjk/software /data/logs
