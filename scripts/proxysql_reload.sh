#!/bin/bash

MASTER=$(curl -s localhost:8500/v1/kv/mysql/master/vgr-cx-msql-01:3306/ipv4 | jq '.[] | .Value' | sed -e 's/"//g' | base64 -d)

mysql -uadmin -padmin --protocol=socket --socket=/var/run/proxysql_admin.sock -e "update mysql_servers set hostname=\"${MASTER}\" where hostgroup_id=0"
mysql -uadmin -padmin --protocol=socket --socket=/var/run/proxysql_admin.sock -e "LOAD MYSQL SERVERS FROM MEMORY"