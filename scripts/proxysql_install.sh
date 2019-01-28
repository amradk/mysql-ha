#!/bin/bash

set -e

#install ProxySQL repo
apt-get install -y lsb-release
wget -O - 'http://repo.proxysql.com/ProxySQL/repo_pub_key' | apt-key add -
echo deb http://repo.proxysql.com/ProxySQL/proxysql-1.4.x/$(lsb_release -sc)/ ./ \
| tee /etc/apt/sources.list.d/proxysql.list

#install ProxySQL
apt-get -y update
apt install -y proxysql mysql-client python3 python3-pip jq
pip3 install mysql-connector
cp /config/configs/proxysql.cnf /etc/
chmod +x /config/scripts/proxysql_reload.sh
service proxysql start