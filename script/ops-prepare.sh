#!/bin/bash
set -x
source ~/keystonerc_admin

# environment
OPS_USER='sysop'
OPS_PASS=${OPS_USER}
OPS_PROJECT='admin'
OPS_PROJECT_ID=$(openstack project show --column id --format value admin)
OPS_NOVA_SECGRP_UUID=$(openstack security group list| grep ${OPS_PROJECT_ID}| awk '{ print $2 }')
OPS_NOVA_SECGRP_ALLOWD_PORT='22 80'
OPS_GLANCE_IMAGE_URL="http://cloud.centos.org/centos/7/images/"
OPS_GLANCE_IMAGE_NAME='CentOS-7-x86_64-GenericCloud-1707.qcow2.xz'
#OPS_NOVA_ALLOWED_CIDR='192.168.6.0/24'

# keystone
openstack user create ${OPS_USER}
openstack role add --user ${OPS_USER} --project admin admin
openstack role add --user ${OPS_USER} --project demo admin
openstack user set --password ${OPS_USER} ${OPS_USER}

# glance
if [ ! -f ${OPS_GLANCE_IMAGE_NAME} ]; then
  curl -o ${OPS_GLANCE_IMAGE_NAME} ${OPS_GLANCE_IMAGE_URL}/${OPS_GLANCE_IMAGE_NAME}
fi
xz -d ${OPS_GLANCE_IMAGE_NAME}
openstack image create \
--disk-format 'qcow2' --min-disk '8' \
--file ${OPS_GLANCE_IMAGE_NAME%%.xz} --public --tag 'centos' \
${OPS_GLANCE_IMAGE_NAME%%.qcow2}

# nova
nova flavor-create test auto 512 20 1 --swap 2 --ephemeral 2
openstack keypair create --public-key ~/.ssh/id_rsa.pub stack
#openstack security group rule create \
#--src-ip ${OPS_NOVA_ALLOWED_CIDR} --protocol 'icmp' --ingress \
#${OPS_NOVA_SECGRP_UUID}
#for port in ${OPS_NOVA_SECGRP_ALLOWD_PORT}; do
#  openstack security group rule create \
#  --src-ip ${OPS_NOVA_ALLOWED_CIDR} --dst-port ${port} --protocol 'tcp' \
#  --ingress --project ${OPS_PROJECT_ID} \
#  ${OPS_NOVA_SECGRP_UUID}
#done
