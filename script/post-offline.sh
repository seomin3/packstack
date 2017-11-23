#!/bin/bash

echo > /etc/resolv.conf
rm -f /etc/yum.repos.d/*
cp /tmp/offline.repo /etc/yum.repos.d/
yum repolist
