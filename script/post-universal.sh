#!/bin/bash

cp -r /tmp/.ssh /root/
chmod 600 /root/.ssh/id_rsa
setenforce 0
systemctl enable network
systemctl disable firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl start network
systemctl stop firewalld
