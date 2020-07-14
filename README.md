# Verify Packstack config
This repository is verifying a configuration of Packstack as an answer file by a Vagrant before realizing an Openstack environment to bare-metal.

## Usage
`vagrant destroy -f; vagrant up`
And then log into the controller
`vagrant ssh packstack-cont`
And then excute packstack
`sudo packstack --answer-file /vagrant/script/ans-stein-vagrant.txt`

