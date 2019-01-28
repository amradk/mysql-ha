#!/bin/bash

mysql -u root -ppassword -e 'create database testdb'
mysql -u root -ppassword -e 'use testdb; create table `data` (id INT AUTO_INCREMENT, str VARCHAR(255), PRIMARY KEY(id))'
