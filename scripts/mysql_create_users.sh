#!/bin/bash

mysql -u root -ppassword -e "GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orchestrator'@'%' IDENTIFIED BY 'orcpass'"
mysql -u root -ppassword -e "GRANT DROP ON _pseudo_gtid_.* to 'orchestrator'@'%'"
mysql -u root -ppassword -e "GRANT SELECT ON mysql.slave_master_info TO 'orchestrator'@'%'"
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON testdb.* TO 'client'@'%' IDENTIFIED BY 'clientpass'"
# monitor user for ProxySQL
mysql -u root -ppassword -e "GRANT USAGE ON *.* TO 'monitor'@'%' IDENTIFIED BY 'monitor'"
mysql -u root -ppassword -e "GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.*  TO 'repl'@'%' IDENTIFIED BY 'replpass'"