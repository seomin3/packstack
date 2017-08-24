#!/bin/bash
set -x
source keystonerc_admin

# environment
OPS_NETWORK=$(openstack network show --column id --format value private)
OPS_IMAGE=$(openstack image show --column id --format value CentOS-7-x86_64-GenericCloud-1707)
OPS_INSTANCE_NAME='sysop-test1'
OPS_FLAVOR=$(openstack flavor show --column id --format value test)
OPS_ZONE='nova'

openstack server create \
--image ${OPS_IMAGE} \
--flavor ${OPS_FLAVOR} \
--key-name stack \
--availability-zone ${OPS_ZONE} \
--nic net-id=${OPS_NETWORK} \
--wait \
${OPS_INSTANCE_NAME}
