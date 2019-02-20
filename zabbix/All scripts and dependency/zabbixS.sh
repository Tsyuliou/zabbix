#!/bin/bash

#First day
#pre install 
yum install net-tools vim \
-y
yum install \
http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm -y
#marinaDB
yum install mariadb mariadb-server -y
yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent \
zabbix-java-gateway -y 


/usr/bin/mysql_install_db --user=mysql
systemctl enable mariadb
systemctl start mariadb
systemctl enable zabbix-agent
systemctl start zabbix-agent
sleep 3
mkdir -p /vagrant/tmp
cd /vagrant/tmp
p=123456
cat << EOF > initialdb 
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by "$p";
EOF

mysql -uroot < initialdb

#Install Zabbix 


zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -p123456 zabbix


#piy=(mysql -uzabbix -p zabbix)
#zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz > /dev/null
#echo $p | passwd $piy --stdin
sed -i 's@# php_value date.timezone Europe/Riga@php_value date.timezone Europe/Minsk@g' /etc/httpd/conf.d/zabbix.conf
sed -i '/DBHost=localhost/s/^#//g' /etc/zabbix/zabbix_server.conf 
sed -i '/DBName=zabbix/s/^#//g' /etc/zabbix/zabbix_server.conf
sed -i '/DBUser=zabbix/s/^#//g' /etc/zabbix/zabbix_server.conf
sed -i '/DBPassword=/s/^#//g' /etc/zabbix/zabbix_server.conf
sed -i 's/DBPassword=/DBPassword=123456/' /etc/zabbix/zabbix_server.conf
sed -i '/DebugLevel=3/s/^#//g' /etc/zabbix/zabbix_agentd.conf
sed -i '/#/d' /etc/httpd/conf/httpd.conf 
sed -i 's/Alias/#Alias/' /etc/httpd/conf.d/zabbix.conf
sed -i '/#/d' /etc/httpd/conf.d/zabbix.conf
echo "DocumentRoot /usr/share/zabbix/" >> /etc/httpd/conf.d/zabbix.conf

#blabla
cat <<EOF > /etc/zabbix/web/zabbix.conf.php
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = '123456';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'Zabbix server';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF



systemctl enable zabbix-server
systemctl start zabbix-server

systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway

systemctl enable httpd
systemctl start httpd

systemctl restart mariadb
systemctl restart zabbix-server
systemctl restart httpd
systemctl restart zabbix-agent
systemctl restart zabbix-java-gateway


systemctl is-active mariadb | echo "mariadb is active"
systemctl is-active zabbix-server | echo "zabbix-server is active"
systemctl is-active httpd | echo "httpd is active"
systemctl is-active zabbix-agent | echo "zabbix-agent is active"
systemctl is-active zabbix-java-gateway | echo "zabbix-java-gateway"
#Second day
