#!/bin/bash
set -x
source ~/keystonerc_admin

# environment
OPS_INSTANCE_NAME=${1:-sysop-test1}
OPS_NETWORK=$(openstack network show --column id --format value ${2:-provider1})
OPS_ZONE=${3:-nova}
OPS_IMAGE=$(openstack image show --column id --format value CentOS-7-x86_64-GenericCloud-1707)
OPS_FLAVOR=$(openstack flavor show --column id --format value ${4:-test})

nova delete ${OPS_INSTANCE_NAME}

openstack server create \
--image ${OPS_IMAGE} \
--flavor ${OPS_FLAVOR} \
--key-name stack \
--availability-zone ${OPS_ZONE} \
--nic net-id=${OPS_NETWORK} \
--wait \
${OPS_INSTANCE_NAME}

nova instance-action-list ${OPS_INSTANCE_NAME}
