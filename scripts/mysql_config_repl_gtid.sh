#!/bin/bash
#title			: replication-start.sh
#description	: This script automates the process of starting a Mysql Replication on 1 master node and N slave nodes.
#author		 	: Nicolas Di Tullio
#date			: 20160706
#version		: 0.2  
#usage			: bash mysql_replication_autostart.sh
#bash_version	: 4.3.11(1)-release
#=============================================================================

#
# Requirements for this script to work:
# * The Mysql user defined by the $USER variable must:
#   - Have the same password $PASS on all mysql instances
#   - Be able to grant replication privileges
#   - All hosts must be able to receive mysql commands remotely from the node executing this script
#

set -e

DB=testdb
DUMP_FILE="/tmp/$DB-export-$(date +"%Y%m%d%H%M%S").sql"

USER=root
PASS=password

MASTER_HOST=172.31.1.101
SLAVE_HOSTS=(172.31.1.102)

##
# MASTER
# ------
# Export database and read log position from master, while locked
##

echo "MASTER: $MASTER_HOST"

mysql -h $MASTER_HOST "-u$USER" "-p$PASS" $DB <<-EOSQL &
	GRANT REPLICATION SLAVE ON *.* TO "$USER"@'%' IDENTIFIED BY "$PASS";
	FLUSH PRIVILEGES;
EOSQL

echo "  - Waiting for database to be locked"
sleep 3

# Dump the database (to the client executing this script) while it is locked
echo "  - Dumping database to $DUMP_FILE"
mysqldump -h $MASTER_HOST "-u$USER" "-p$PASS" --all-databases --triggers --routines --events --single-transaction > $DUMP_FILE
echo "  - Dump complete."

##
# SLAVES
# ------
# Import the dump into slaves and activate replication with
# binary log file and log position obtained from master.
##

for SLAVE_HOST in "${SLAVE_HOSTS[@]}"
do
	echo "SLAVE: $SLAVE_HOST"
	echo "  - Creating database copy"
	mysql -h $SLAVE_HOST "-u$USER" "-p$PASS" -e "RESET MASTER"
	cat $DUMP_FILE | mysql -h $SLAVE_HOST "-u$USER" "-p$PASS"

	echo "  - Setting up slave replication"
	mysql -h $SLAVE_HOST "-u$USER" "-p$PASS" $DB <<-EOSQL &
		STOP SLAVE;
		CHANGE MASTER TO MASTER_HOST='$MASTER_HOST',
		MASTER_USER='repl',
		MASTER_PASSWORD='replpass',
		MASTER_AUTO_POSITION=1;
		START SLAVE;
	EOSQL
	# Wait for slave to get started and have the correct status
	sleep 2
	# Check if replication status is OK
	SLAVE_OK=$(mysql -h $SLAVE_HOST "-u$USER" "-p$PASS" -e "SHOW SLAVE STATUS\G;" | grep 'Waiting for master')
	if [ -z "$SLAVE_OK" ]; then
		echo "  - Error ! Wrong slave IO state."
	else
		echo "  - Slave IO state OK"
	fi
done