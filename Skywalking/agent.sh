skywalking_agent_directory: /data/xjk/static/gamma-o/skywalking-agent

/usr/local/jdk/bin/java -javaagent:/data/xjk/static/skywalking-agent/skywalking-agent.jar -Dskywalking.agent.service_name=gammao-ipass -Dskywalking.collector.backend_service=10.132.4.164:12800 -jar ${appName}-${envName}.jar  

java -jar gammao-ipaas-server.jar server.properties

164


ansible 10.132.4.140 -m copy -a "src=/data/xjk/javamain/200629/skywalking-agent.7z dest=/data/xjk/javamain/200629/skywalking-agent.7z backup=yes"






nohup java -javaagent:/data/xjk/static/skywalking-agent/skywalking-agent.jar -Dskywalking.agent.service_name=gammao-ipaas -Dskywalking.collector.backend_service=10.132.4.164:12800 -jar gammao-ipaas-server.jar server.properties > /data/logs/javamain/ipass-server/gammao-ipass.20200629.log 2>&1 &