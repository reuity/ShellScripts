#!/bin/bash
set -e
#check_usage
if [ $# -ne 1 ]; then
    echo "Usage: $0 jdkPKG"
    exit 1
fi

# Need to modify
#=================#
user=wls81
group=wls
baseDir=/apphome/soft
#=================#
fileName=$(tar -tf $1 | head -1 | cut -d/ -f1)
mkdir -p ${baseDir}

if ! java -version &>/dev/null && ! ${baseDir}/jdk/bin/java -version &>/dev/null; then
    echo "Extracting..."
    tar -zxf $1 -C ${baseDir}
    ln -snf ${baseDir}/${fileName} ${baseDir}/jdk
    echo -e "
export JAVA_HOME=${baseDir}/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
" >>/etc/profile
else
    echo "jdk has already installed!"
    exit 1
fi
source /etc/profile
chown -R ${user}.${group} ${baseDir}/jdk
java -version
