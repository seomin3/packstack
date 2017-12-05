#!/bin/bash

if [ $(hostname) == 'packstack-cont' ]; then
  yum install -y centos-release-openstack-pike
  yum update -y
  yum install -y openstack-packstack
fi
