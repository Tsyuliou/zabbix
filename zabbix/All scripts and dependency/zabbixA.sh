#!/bin/bash
#First Day
yum install net-tools vim \
-y

yum install \
http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm -y

yum install zabbix-agent -y

sed -i '/DebugLevel=3/s/^#//g' /etc/zabbix/zabbix_agentd.conf
sed -i '/ListenPort=10050/s/^#//g' /etc/zabbix/zabbix_agentd.conf
sed -i '/ListenIP=0.0.0.0/s/^#//g' /etc/zabbix/zabbix_agentd.conf
sed -i '/StartAgents=3/s/^#//g' /etc/zabbix/zabbix_agentd.conf
sed -i 's#Server=127.0.0.1#Server=192.168.56.2#g' /etc/zabbix/zabbix_agentd.conf
sed -i 's#ServerActive=127.0.0.1#ServerActive=192.168.56.2#g' /etc/zabbix/zabbix_agentd.conf
echo "HostMetadata=system.uname" >> /etc/zabbix/zabbix_agentd.conf


systemctl enable zabbix-agent
systemctl start zabbix-agent

















