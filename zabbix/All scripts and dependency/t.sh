 #!/bin/bash

#pre-install /try new feature for me just in this part
#but I think my idea is clear.

rpm -qa | grep -w httpd-devel || yum install httpd-devel -y
rpm -qa | grep -w apr-1 ||yum install apr -y
rpm -qa | grep -w apr-devel ||yum install apr-devel -y 
rpm -qa | grep -w apr-util-1 ||yum install apr-util -y
rpm -qa | grep -w apr-util-devel ||yum install apr-util-devel -y 
rpm -qa | grep -w gcc-4 ||yum install gcc -y
rpm -qa | grep -w gcc-c++ ||yum install gcc-c++ -y
rpm -qa | grep -w make ||yum install make -y
rpm -qa | grep -w autoconf ||yum install autoconf -y
rpm -qa | grep -w libtool ||yum install libtool -y
rpm -qa | grep -w vim-enhanced ||yum install vim -y

#

if [[ -d /opt/tomcat ]]
 then echo "/opt/tomcat currently exist"
 else mkdir -p /opt/tomcat
fi

#download tomcat
cd /tmp
p="tomcat"
cat /etc/passwd | grep -w tomcat || useradd tomcat \
echo $p | passwd tomcat --stdin

wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz
sleep 15
tar -xf apache-tomcat-9.0.16.tar.gz
sleep 5
mv /tmp/apache-tomcat-9.0.16/* /opt/tomcat
#ln -s /opt/tomcat/apache-tomcat-9.0.14 /opt/tomcat/latest
chown -R tomcat: /opt/tomcat
chmod +x -R /opt/tomcat/bin/*.sh
#chmod +x -R /opt/tomcat/apache-tomcat-9.0.14/bin/*

# add permissions to all directories and change owner:group
echo " 
[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment=JAVA_HOME=/usr/java/jdk1.8.0_131/jre
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid


ExecStart=/opt/tomcat/bin/catalina.sh start
ExecStop=/opt/tomcat/bin/catalina.sh stop
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/tomcat.service


#alternatives --config java <<< '1'

sleep 5

systemctl daemon-reload

sleep 3

systemctl enable tomcat
systemctl start tomcat
systemctl status tomcat
 
#TASK
#sleep 10 
#bash /vagrant/mv.sh

#download simple war app
cd /tmp
wget https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war
mv sample.war /opt/tomcat/webapps/
chown -R tomcat: /opt/tomcat/webapps
chmod +x /opt/tomcat/webapps/sample.war


cat << EOF >/opt/tomcat/bin/setenv.sh
export JAVA_OPTS="-Dcom.sun.management.jmxremote=true \n
-Dcom.sun.management.jmxremote.port=12345 \n
-Dcom.sun.management.jmxremote.rmi.port=12346 \n
-Dcom.sun.management.jmxremote.ssl=false \n
-Dcom.sun.management.jmxremote.authenticate=false \n
-Djava.rmi.server.hostname=192.168.56.3" n
EOF
chmod +x /opt/tomcat/bin/setenv.sh
chown tomcat:tomcat /opt/tomcat/bin/setenv.sh

sed -i 's/.$//' /opt/tomcat/bin/setenv.sh

cd /opt/tomcat/lib
wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.28/bin/extras/catalina-jmx-remote.jar 
chown tomcat:tomcat /opt/tomcat/lib/catalina-jmx-remote.jar


sed -i '/<Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" \/>/a \<Listener className="org.apache.catalina.mbeans.JmxRemoteLifecycleListener" rmiRegistryPortPlatform="8097" rmiServerPortPlatform="8098" />' /opt/apache/tomcat/conf/server.xml


cd /vagrant/
bash api.sh
systemctl restart zabbix-server

