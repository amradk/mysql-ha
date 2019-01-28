#!/bin/bash

wget https://github.com/github/orchestrator/releases/download/v3.0.12/orchestrator_3.0.12_amd64.deb > /dev/null
dpkg -i orchestrator_3.0.12_amd64.deb
wget https://github.com/github/orchestrator/releases/download/v3.0.12/orchestrator-cli_3.0.12_amd64.deb > /dev/null
dpkg -i orchestrator-cli_3.0.12_amd64.deb
apt install -y mysql-client-core-5.7

apt install -y jq
wget https://github.com/github/orchestrator/releases/download/v3.0.12/orchestrator-client_3.0.12_amd64.deb > /dev/null
dpkg -i ./orchestrator-client_3.0.12_amd64.deb

cp /config/configs/orchestrator.conf.json /etc/orchestrator.conf.json
sudo mkdir /var/lib/orchestrator 
sudo /etc/init.d/orchestrator restart

sudo orchestrator -c discover -i msql-01
sudo orchestrator-client -c submit-masters-to-kv-stores