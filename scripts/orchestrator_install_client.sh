#!/bin/bash

apt install -y jq
wget https://github.com/github/orchestrator/releases/download/v3.0.12/orchestrator-client_3.0.12_amd64.deb > /dev/null
dpkg -i ./orchestrator-client_3.0.12_amd64.deb
apt install -y mysql-client-core-5.7