#!/bin/bash
set -e
# Variables
#==========================================#
user=wls81
group=wls
jdkPKG=jdk-8u91-linux-x64.tar.gz
baseDir=/apphome/soft
logDir=/apphome/logs/tomcat_${appName}
repoDir=/apphome/xjk/tomcat/${appName}
#==========================================#

# check_usage
if [[ $1 -gt 4 && $1 -lt 9 || $# != 3 ]]; then
    echo -e "Usage: $0 num(<=3) $appName $tomcatPKG
    Port=8080+num"
    exit 1
fi

# install_jdk function
install_jdk() {
    /bin/bash ${scriptDir}/jdk_install.sh ${jdkPKG}
}

appName=$2
package=$3

tomcatDir=${baseDir}/tomcat_${appName}
mkdir -p ${baseDir} ${logDir} ${repoDir}

fileName=$(tar -tf ${package} | head -1 | cut -d/ -f1)
scriptDir=$(dirname $0)
install_jdk
mkdir -p $scriptDir/temp
tar --skip-old-files -zxf ${package} -C $scriptDir/temp

if [[ ! -d ${tomcatDir} ]]; then
    \cp -r $scriptDir/temp/$fileName ${tomcatDir}
else
    echo -e "${tomcatDir} is already exist!" && exit 1
fi

sed -i s@\$CATALINA_OUT_DEF@${logDir}/catalina.out@g ${tomcatDir}/bin/catalina.sh
sed -i s/\$SHUTDOWNPORT/$((8005 + $1))/g ${tomcatDir}/conf/server.xml
sed -i s/\$HTTPPORT/$((8080 + $1))/g ${tomcatDir}/conf/server.xml
sed -i s/\$AJPPORT/$((8009 + $1))/g ${tomcatDir}/conf/server.xml
sed -i s/\$HTTPSPORT/8443/g ${tomcatDir}/conf/server.xml
sed -i s@\$appBase_DEF@${repoDir}@g ${tomcatDir}/conf/server.xml
chown -R ${user}.${group} ${baseDir} ${logDir}

# create restart script
userHome=$(cat /etc/passwd | grep $user | cut -d: -f 6)

if [[ ! -f ${userHome}/shell/tomkill.sh ]]; then
    mkdir -p ${userHome}/shell
    \cp tomkill.sh ${userHome}/shell/tomkill.sh
    sed -i s@\$baseDir@${baseDir}@g ${userHome}/shell/tomkill.sh
    chmod +x ${userHome}/shell/tomkill.sh
    chown -R ${user}.${group} ${userHome}/shell
fi

\cp t#_restart.sh ${userHome}/t$1_${appName}_restart.sh
sed -i s@\$appName@${appName}@g ${userHome}/t$1_${appName}_restart.sh
sed -i s@\$logDir@${logDir}@g ${userHome}/t$1_${appName}_restart.sh
chmod +x ${userHome}/t$1_${appName}_restart.sh
chown -R ${user}.${group} ${userHome}/t$1_${appName}_restart.sh

echo "tomcat_${appName} install successfully!"
