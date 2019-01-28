#!/bin/bash

#echo 'DAEMONOPTS="--config=/etc/orchestrator.conf $DAEMONOPTS"' > /etc/default/orchestrator
cp /config/scripts/orchestrator.conf.json /etc/orchestrator.conf.json
sudo mkdir /var/lib/orchestrator 
sudo /etc/init.d/orchestrator restart