#!/bin/bash

CONSUL_VERSION="1.0.7"

wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
if [ -a ./consul_${CONSUL_VERSION}_linux_amd64.zip ]
then
    mkdir -p /opt/consul/${CONSUL_VERSION}
    mkdir -p /run/consul
    unzip ./consul_${CONSUL_VERSION}_linux_amd64.zip
    mv ./consul /opt/consul/${CONSUL_VERSION}/
    cp /config/configs/consul_server.json /etc/consul.json
    cp /config/configs/consul.service /etc/systemd/system/
    sed -ie "s/VER/${CONSUL_VERSION}/" /etc/systemd/system/consul.service
    systemctl daemon-reload
    systemctl start consul
fi