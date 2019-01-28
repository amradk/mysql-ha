#!/bin/bash

HOSTNAME=$(hostname -s)
SRV_ID=${HOSTNAME: -1}
echo "server-id=${SRV_ID}" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "binlog_format=MIXED" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "character-set-server=utf8" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "collation-server=utf8_bin" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "default-storage-engine=INNODB" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "log-bin=mysql-bin" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "gtid-mode=ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "enforce-gtid-consistency=ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "innodb_file_per_table=ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "innodb_flush_log_at_trx_commit=2" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "innodb_flush_method=O_DSYNC" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "skip_name_resolve=ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i 's/127\.0\.0\.1/0\.0\.0\.0/'  /etc/mysql/mysql.conf.d/mysqld.cnf
# for slaves
if [ ${SRV_ID} -gt 1 ]
then
echo "read_only=ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "log_slave_updates=ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf
fi
systemctl restart mysql

# config users
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION"
mysql -u root -ppassword -e 'create database testdb'
mysql -u root -ppassword -e 'use testdb; create table `data` (id INT AUTO_INCREMENT, str VARCHAR(255), PRIMARY KEY(id))'
mysql -u root -ppassword -e "GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO 'orchestrator'@'%' IDENTIFIED BY 'orcpass'"
mysql -u root -ppassword -e "GRANT DROP ON _pseudo_gtid_.* to 'orchestrator'@'%'"
mysql -u root -ppassword -e "GRANT SELECT ON mysql.slave_master_info TO 'orchestrator'@'%'"
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON testdb.* TO 'client'@'%' IDENTIFIED BY 'clientpass'"
# monitor user for ProxySQL
mysql -u root -ppassword -e "GRANT USAGE ON *.* TO 'monitor'@'%' IDENTIFIED BY 'monitor'"
mysql -u root -ppassword -e "GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.*  TO 'repl'@'%' IDENTIFIED BY 'replpass'"