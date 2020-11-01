#!/bin/bash
basepath=/data/xjk/
jarpath=$basepath/javamain
repopath=$basepath/repository

subSystem=smelp-scf
appName=scf-external-services-server
envName=stg
config="/data/xjk/javamain/config/$subSystem/$appName"

processKey="${appName}-${envName}.jar"
startDir=${jarpath}/${subSystem}/${appName}_${envName}
startCmd="nohup /usr/local/jdk/bin/java -jar ${appName}-${envName}.${packagetype} &>/data/logs/javamain/${appName}.log &"



# kill process
kill_process() {
    ps aux | grep "${processKey}" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
    sleep 5
    COUNT=$(ps aux | grep "${processKey}" | grep -v grep | wc -l)
    if [[ $COUNT == 0 ]]; then
        echo "kill successfully"
    else
        echo "kill failed"
        exit 1
    fi
}

# start process
start_process() {
    cd ${startDir}
    ${startCmd}
    if [ $? -eq 0 ]; then
        echo "start successfully"
    else
        echo "start failed"
        exit 1
    fi
}

kill_process
start_process

nohup /usr/local/jdk8/bin/java -Xms256M -Xmx256M -cp "$config:$jarpath/$subSystem/$appName/${appName}-${envName}.jar" org.springframework.boot.loader.JarLauncher >/data/logs/javamain/scf/scf-external-service/nohup.out 2>&1 &

nohup /apphome/soft/jdk/bin/java ${appName}.jar
