#!/bin/bash
set -e

# VARIABLES
#=====================#
user=root
group=root
baseDir=/usr/local
#=====================#

# check_usage
if [ $# -ne 1 ]; then
    echo "Usage: $0 JDKPKG | clean"
    exit 1
fi

case $1 in
"clean") # clean up
    sed -i "/^[^#]/{/JAVA_HOME/d}" /etc/profile
    # get jdk's real dirname
    link=$(expr "$(ls -ld ${baseDir}/jdk)" : '.*-> \(.*\)$')
    rm -rf ${baseDir}/jdk ${link}
    echo "Cleaned Up"
    ;;
*) # install jdk in ${baseDir}
    # get jdk's dirname
    fileName=$(tar -tf $1 | head -1 | cut -d/ -f1)
    mkdir -p ${baseDir}
    if ( (java -version &>/dev/null) || (${baseDir}/jdk/bin/java -version &>/dev/null)); then
        echo "jdk has already installed!"
        exit 0
    else
        echo "Installing..."
        tar -zxf $1 -C ${baseDir}
        ln -snf ${baseDir}/${fileName} ${baseDir}/jdk
        sed -i "/^[^#]/{/JAVA_HOME/d}" /etc/profile
        echo -e "\nexport JAVA_HOME=${baseDir}/jdk" \
        "\nexport PATH=\$JAVA_HOME/bin:\$PATH" \
        "\nexport CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >>/etc/profile
    fi
    chown -R ${user}.${group} ${baseDir}/jdk
    ${baseDir}/jdk/bin/java -version
    echo -e "Successfully." \
    "\n jdk in : ${baseDir}/${fileName}" \
    "\nsoftlink: ${baseDir}/jdk" \
    "\nrun: source /etc/profile"
    ;;
esac
