#!/bin/bash

#login/token
gettoken=`curl -i -k -X POST -H 'Content-Type: application/json-rpc' -d " 
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.login\",
    \"params\": {
        \"user\": \"Admin\",
        \"password\": \"zabbix\"
    },
    \"id\": 1,
    \"auth\": null
}" http://192.168.56.2/api_jsonrpc.php`

token=`echo $gettoken |cut -d\" -f8`
echo $token


#hostid and main check

host=`curl -i -k -X POST -H 'Content-Type: application/json-rpc' -d " 
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"filter\": {
            \"host\": [
                \"Linux server\"
            ]
        }
    },
    \"auth\": \"$token\",
    \"id\": 1
}" http://192.168.56.2/api_jsonrpc.php`

hostid=`echo $host |cut -d\" -f10`
echo $host
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! $hostid !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

#if [[ $hostid -ne 0 ]]
#	then echo "Host Linux server already exist!!!"
#	else 
	#templateid

	template=`curl -i -k -X POST -H 'Content-Type: application/json-rpc' -d " 
	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"template.get\",
	    \"params\": {
	        \"output\": \"extend\",
	        \"filter\": {
	            \"host\": [
	                \"Template OS Linux\"                
	            ]
	        }
	    },
	    \"auth\": \"$token\",
	    \"id\": 1
	}" http://192.168.56.2/api_jsonrpc.php`

	templateid=`echo $template |cut -d\" -f130`
echo $template
echo $templateid
	#groupid

	group=`curl -i -k -X POST -H 'Content-Type: application/json-rpc' -d " 
	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"hostgroup.get\",
	    \"params\": {
	        \"output\": \"extend\",
	        \"filter\": {
	            \"name\": [                
	                \"Project Hosts\"
	            ]
	        }
	    },
	    \"auth\": \"$token\",
	    \"id\": 1
	}" http://192.168.56.2/api_jsonrpc.php`

	groupid=`echo $group |cut -d\" -f10`

	#get ip
	ip=`ip a |grep inet | grep 192.168.56`
	t=`echo $ip | awk '{print$2}' | cut -d/ -f1`

echo $group
echo $groupid

	#createhost

	hostc=`curl -i -k -X POST -H 'Content-Type: application/json-rpc' -d " 
	{
	    \"jsonrpc\": \"2.0\",
	    \"method\": \"host.create\",
	    \"params\": {
	        \"host\": \"Linux server\",
	        \"interfaces\": [
	            {
	                \"type\": 1,
	                \"main\": 1,
	                \"useip\": 1,
	                \"ip\": \"\$t\",
	                \"dns\": \"\",
	                \"port\": \"10050\"
	            }
	        ],
	        \"groups\": [
	            {
	                \"groupid\": \"\$groupid\"
	            }
	        ],
	        \"templates\": [
	            {
	                \"templateid\": \"\$templateid\"
	            }
	        ],
	        \"inventory_mode\": 0,
	        \"inventory\": {
	            \"macaddress_a\": \"01234\",
	            \"macaddress_b\": \"56768\"
	        }
	    },
	    \"auth\": \"\$token\",
	    \"id\": 1
	}" http://192.168.56.2/api_jsonrpc.php`

	echo "Host Linux server was created!!!"
	echo $hostc
	
#fi


























