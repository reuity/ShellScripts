#!/bin/bash
set -e

# VARIABLES
#=====================#
user=wls81
group=wls
baseDir=/usr/local
#=====================#

# check_usage
if [ $# -ne 1 ]; then
    echo "Usage: $0 JDKPKG|clean"
    exit 1
fi

abc=$1

case $abc in
"clean")
    # clean up
    sed -i "/^[^#]/{/JAVA_HOME/d}" /etc/profile
    rm -rf ${baseDir}/${fileName} ${baseDir}/jdk
    source /etc/profile
    echo "Cleaned Up"
    ;;
*)
    # get jdk's dirname
    fileName=$(tar -tf $1 | head -1 | cut -d/ -f1)
    mkdir -p ${baseDir}

    if ( (java -version &>/dev/null) || (${baseDir}/jdk/bin/java -version &>/dev/null)); then
        echo "jdk has already installed!"
        exit 1
    else
        #install jdk in ${baseDir}
        echo "Installing..."
        tar -zxf $1 -C ${baseDir}
        ln -snf ${baseDir}/${fileName} ${baseDir}/jdk
        sed -i "/^[^#]/{/JAVA_HOME/d}" /etc/profile
        echo -e "\nexport JAVA_HOME=${baseDir}/jdk" \
            "\nexport PATH=\$JAVA_HOME/bin:\$PATH" \
            "\nexport CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >>/etc/profile
    fi
    source /etc/profile
    chown -R ${user}.${group} ${baseDir}/jdk
    java -version
    echo "Successfully.\n" \
        " jdk in : ${baseDir}/${fileName}\n" \
        "softlink: ${baseDir}/jdk\n" \
        "run: source /etc/profile\n"
    ;;
esac
