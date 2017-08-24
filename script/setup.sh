#!/bin/bash

OPENSTACK_BRANCH='stable/newton'
RUBY_VERSION='2.3'
RUBY_DIR='/usr/local/rvm'
PACKSTACK_DIR='/root/packstack'

# install gem
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
if [ ! -f ${RUBY_DIR}/bin/rvm ]; then
  \curl -sSL https://get.rvm.io | bash -s stable
  usermod -aG rvm vagrant
  source /etc/profile.d/rvm.sh
fi

if [ ! -f ${RUBY_DIR}/bin/gem ]; then
  rvm install ${RUBY_VERSION}
  rvm alias create default ${RUBY_VERSION}
fi

# pip
yum -y -d 1 install python-devel
curl -sSL https://bootstrap.pypa.io/get-pip.py | python

# clone packstack repository
yum -y -d 1 install git
if [ ! -f ~/packstack ]; then
  git clone git://github.com/openstack/packstack.git -b ${OPENSTACK_BRANCH} ${PACKSTACK_DIR}
fi

# gem module & puppet
cd ${PACKSTACK_DIR}
gem install r10k bundler
bundle install
r10k puppetfile install -v
cp -r packstack/puppet/modules/packstack /usr/share/openstack-puppet/modules
mkdir -p /etc/puppetlabs/puppet/
cat << EOM > /etc/puppetlabs/puppet/hiera.yaml
---
:backends:
  - yaml
:hierarchy:
  - defaults
  - "%{clientcert}"
  - "%{environment}"
  - global

:yaml:
# datadir is empty here, so hiera uses its defaults:
# - /var/lib/hiera on *nix
# - %CommonAppData%\PuppetLabs\hiera\var on Windows
# When specifying a datadir, make sure the directory exists.
  :datadir: /var/tmp/packstack/latest/hieradata
EOM

# ruby augeas
yum install -y augeas-devel
gem install ruby-augeas

# packstack
pip install -r requirements.txt
python setup.py install
packstack --gen-answer-file=ans.txt
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# package
yum install -y centos-release-openstack-newton
yum -y -d 1 install vim htop screen

#ifup eth1
