#!/bin/bash

cd /opt/consul
curl -O https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.zip
unzip ./consul-template_0.19.5_linux_amd64.zip
cp -f /config/scripts/consul-template.service /etc/systemd/system/
mkdir -p /etc/consul-template
cp -f /config/configs/consul-template.hcl /etc/
cp -f /config/configs/proxysql.ctmpl /etc/consul-template/
systemctl daemon-reload
systemctl start consul-template

