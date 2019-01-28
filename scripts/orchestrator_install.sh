#!/bin/bash

wget https://github.com/github/orchestrator/releases/download/v3.0.12/orchestrator_3.0.12_amd64.deb > /dev/null
dpkg -i orchestrator_3.0.12_amd64.deb
wget https://github.com/github/orchestrator/releases/download/v3.0.12/orchestrator-cli_3.0.12_amd64.deb > /dev/null
dpkg -i orchestrator-cli_3.0.12_amd64.deb
apt install -y mysql-client-core-5.7