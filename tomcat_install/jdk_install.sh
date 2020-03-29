#!/bin/bash
set -e

# VARIABLES
#=====================#
user=wls81
group=wls
baseDir=/user/local
#=====================#

# check_usage
if [ $# -ne 1 ]; then
    echo "Usage: $0 jdkPKG"
    exit 1
fi

# get jdk's dirname
fileName=$(tar -tf $1 | head -1 | cut -d/ -f1)
mkdir -p ${baseDir}

if ( (java -version &>/dev/null) || (${baseDir}/jdk/bin/java -version &>/dev/null)); then
    echo "jdk has already installed!"
    exit 1
else
    #install jdk in ${baseDir}
    echo "Extracting..."
    tar -zxf $1 -C ${baseDir}
    ln -snf ${baseDir}/${fileName} ${baseDir}/jdk
    sed -i "/^[^#]/{/JAVA_HOME/d}" /etc/profile
    echo -e "
export JAVA_HOME=${baseDir}/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
" >>/etc/profile
fi

source /etc/profile
chown -R ${user}.${group} ${baseDir}/jdk
java -version
echo " jdk in : ${baseDir}/${fileName}
softlink: ${baseDir}/jdk"
