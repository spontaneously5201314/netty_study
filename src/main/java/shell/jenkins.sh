#!/bin/bash

compile_dir="/opt/jenkins/compile"
rm -rf ${compile_dir}/*
if [ ! -d "${compile_dir}" ]; then
    mkdir -p "${compile_dir}"
fi

#判断是否正在部署，如果是则退出
if [ -f "${compile_dir}/.run" ]; then
    echo "程序部署中，请勿重复部署!"
    exit 1
fi

#创建.run文件，标识脚本正在部署
touch "${compile_dir}/.run"
#捕获Ctrl+C,删除.run文件，避免状态不一致
trap "rm -r ${compile_dir}/.run; exit 1" 2

echo "##############################################################"
echo "                开始从git代码库下载最新的代码                      "
echo "##############################################################"
cd ${compile_dir}
git clone https://hongfei%40cmcm.com:HF%4084,520hz%21@gitbj.cmcm.com/NaughtyCheetahStudio/AB-dcserver.git

echo "##############################################################"
echo "                        开始编译代码                            "
echo "##############################################################"
#cp -rf cmp-web/src/main/config/config_test/* cmp-web/src/main/resources/
#todo 这里还不是很清楚怎么去处理文件夹里面的东西
cd ${compile_dir}/AB-dcserver
mvn clean package -DskipTests -U

if [ $? != 0 ]; then
    echo "##############################################################"
    echo -e 'mvn打包出错了，直接退出部署程序。。。';
    echo "##############################################################"
    exit 1
fi

#删除.run文件，部署完毕
rm -r ${compile_dir}/.run;

echo "##############################################################"
echo -e "                   开始部署AB-Server                         "
echo "##############################################################"
ps -ef  | grep "AB-dcserver" | grep -v grep | awk  '{print $2}' | xargs kill -9
java -Xmx1024m -Xss256k -jar /opt/jenkins/compile/AB-dcserver/ab-dc-registry-server/target/registry-server-1.0.0-SNAPSHOT.jar --spring.config.location=application.properties  --server.port=8761 > /data/logs/arrow/registry.log 2>&1 &
sleep 5

registry=`ps -ef | grep "registry-server-1.0.0-SNAPSHOT.jar" | grep -v grep | awk  '{print $2}'`
echo "############################注册服务启动的端口号是：${registry}##################################"

java -Xmx1024m -Xss256k -jar /opt/jenkins/compile/AB-dcserver/ab-dc-gateway/target/ab-dc-gateway-1.0.0-SNAPSHOT.jar --spring.config.location=application.properties  --server.port=9090 > /data/logs/arrow/gateway_9090.log 2>&1 &
gateway=`ps -ef | grep "gateway" | grep -v grep | awk  '{print $2}'`
echo "############################网关服务启动的端口号是：${gateway}##################################"

java -Xmx1024m -Xss256k -jar /opt/jenkins/compile/AB-dcserver/ab-dc-account/account-api/target/account-api-1.0.0-SNAPSHOT.jar --spring.config.location=application.properties  --server.port=20881 > /data/logs/arrow/account_20881.log 2>&1 &
java -Xmx1024m -Xss256k -jar /opt/jenkins/compile/AB-dcserver/ab-dc-account/account-api/target/account-api-1.0.0-SNAPSHOT.jar --spring.config.location=application.properties  --server.port=20882 > /data/logs/arrow/account_20882.log 2>&1 &
java -Xmx1024m -Xss256k -jar /opt/jenkins/compile/AB-dcserver/ab-dc-hero/hero-api/target/hero-api-1.0.0-SNAPSHOT.jar --spring.config.location=application.properties  --server.port=20883 > /data/logs/arrow/hero_20883.log 2>&1 &
java -Xmx1024m -Xss256k -jar /opt/jenkins/compile/AB-dcserver/ab-dc-hero/hero-api/target/hero-api-1.0.0-SNAPSHOT.jar --spring.config.location=application.properties  --server.port=20884 > /data/logs/arrow/hero_20884.log 2>&1 &
account=`ps -ef | grep "account-api" | grep -v grep | wc -l`
hero=`ps -ef | grep "hero-api" | grep -v grep | wc -l`
echo "############################总共启动了${account}个account服务##################################"
echo "############################总共启动了${hero}个hero服务##################################"
#第一个hero的端口是8090
#cp /opt/jenkins/compile/AB-dcserver/ab-dc-hero/hero-api/target/ab-dc-hero-api-1.0.0-SNAPSHOT.war /opt/tomcat/hero1/webapps/ROOT.war && sh /opt/tomcat/hero1/bin/startup.sh
#第一个hero的端口是8091
#cp /opt/jenkins/compile/AB-dcserver/ab-dc-hero/hero-api/target/ab-dc-hero-api-1.0.0-SNAPSHOT.war /opt/tomcat/hero2/webapps/ROOT.war && sh /opt/tomcat/hero2/bin/startup.sh