#!/bin/bash
set -e

# use "top -c" find pid with high CPU usage
# then sh $0 pid

# check usage
if [[ $# < 1 && $# > 2 ]]; then
    echo "usage: $0 <pid> [line-number]"
    exit 1
fi

# java home
if [ -z ${JAVA_HOME} ]; then
    echo "JAVA_HOME is not exists!"
    exit 1
fi

# get variable
pid=$1
linenum=$2
date=$(date +%H%M%S)

# check if pid exists
if test -z "$(${JAVA_HOME}/bin/jps -l | cut -d '' -f 1 | grep ${pid})"; then
    echo "process of ${pid} is not exists"
    exit 1
fi

# line number
if [ -z ${linenum} ]; then
    linenum=10
fi

stackfile=${pid}-stack-${date}.dump
threadsid=${pid}-threades-${date}.dump
exceptionfile=${pid}-exceptionfile-${date}.dump

# generate java stack
${JAVA_HOME}/bin/jstack -l ${pid} >${stackfile}
ps -mp ${pid} -o THREAD,tid,time | sort -k2r | awk '{if ($1 !="USER" && $2 != "0.0" && $8 !="-") print $8;}' | xargs printf "%x\n" >${threadsid}

# print exception dump
echo -e "\n-------------------------------------\n" | tee -a ${exceptionfile}
for i in $(cat ${threadsid}); do
    if [ $i != 0 ]; then
        grep ${i} -A ${linenum} ${stackfile} | tee -a ${exceptionfile}
        echo -e "\n-------------------------------------\n" | tee -a ${exceptionfile}
    fi
done
