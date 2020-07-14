#!/bin/bash

cp -r /tmp/.ssh /root/
chmod 600 /root/.ssh/id_rsa
setenforce 0
