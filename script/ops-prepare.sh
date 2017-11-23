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
OPS_GLANCE_IMAGE_URL='http://192.168.30.2/cloud'
OPS_GLANCE_IMAGE_NAME='CentOS-7-x86_64-GenericCloud-1707.qcow2.xz'
OPS_NOVA_ALLOWED_CIDR='192.168.6.0/24'

# keystone
openstack user create ${OPS_USER}
openstack role add --user ${OPS_USER} --project admin admin
openstack role add --user ${OPS_USER} --project demo admin
openstack user set --password ${OPS_USER} ${OPS_USER}

[ ! -f sysop.osrc ] && cat > ./sysop.osrc <<EOT
unset OS_SERVICE_TOKEN
export OS_USERNAME=sysop
export OS_PASSWORD=sysop
export OS_AUTH_URL=http://192.168.30.152:5000/v3
export PS1='[\u@\h \W(sysop)]\$ '
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
EOT

# glance
if [ ! -f ${OPS_GLANCE_IMAGE_NAME} ]; then
  curl -o ${OPS_GLANCE_IMAGE_NAME} ${OPS_GLANCE_IMAGE_URL}/${OPS_GLANCE_IMAGE_NAME}
fi
xz -d ${OPS_GLANCE_IMAGE_NAME}
openstack image create \
--disk-format 'qcow2' --min-disk '8' \
--file ${OPS_GLANCE_IMAGE_NAME%%.xz} --public --tag 'centos' \
${OPS_GLANCE_IMAGE_NAME%%.qcow2.xz}

# nova
nova flavor-create test auto 512 20 1 --swap 2 --ephemeral 2
openstack security group rule create \
--src-ip ${OPS_NOVA_ALLOWED_CIDR} --protocol 'icmp' --ingress \
${OPS_NOVA_SECGRP_UUID}
for port in ${OPS_NOVA_SECGRP_ALLOWD_PORT}; do
  openstack security group rule create \
  --src-ip ${OPS_NOVA_ALLOWED_CIDR} --dst-port ${port} --protocol 'tcp' \
  --ingress --project ${OPS_PROJECT_ID} \
  ${OPS_NOVA_SECGRP_UUID}
done

source sysop.osrc
openstack keypair create --public-key ~/.ssh/id_rsa.pub stack
