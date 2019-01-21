# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base VM OS configuration.
  config.vm.box = "centos/7"
  config.ssh.insert_key = true
  # plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = true
  config.vbguest.auto_update = false

  # General VirtualBox VM configuration.
  config.vm.provider :virtualbox do |v|
    v.linked_clone = true
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # controller
  config.vm.define "packstack-cont" do |node|
    node.vm.hostname = "packstack-cont"
    config.vm.synced_folder ".", "/vagrant", type: "nfs"
    node.vm.network :private_network, ip: "192.168.30.5"
    node.vm.network :private_network, ip: "172.16.255.5"
    node.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", 6144]
      v.customize ["modifyvm", :id, "--cpus", 4]
      # for Cinder
      unless File.exist?('./cinder-volumes.vdi')
        v.customize ['createhd', '--filename', './cinder-volumes.vdi', '--variant', 'Fixed', '--size', 10 * 1024]
      end
      v.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './cinder-volumes.vdi']
    end
  end

  # compute
  config.vm.define "packstack-comp1" do |node|
    node.vm.hostname = "packstack-comp1"
    node.vm.network :private_network, ip: "192.168.30.6"
    node.vm.network :private_network, ip: "172.16.255.6"
    node.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--cpus", 1]
    end
  end
  config.vm.define "packstack-comp2" do |node|
    node.vm.hostname = "packstack-comp2"
    node.vm.network :private_network, ip: "192.168.30.7"
    node.vm.network :private_network, ip: "172.16.255.7"
    node.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--cpus", 1]
    end
  end

  config.vm.provision "file", source: "script/.ssh/", destination: "/tmp/"
  config.vm.provision "file", source: "script/repo.conf", destination: "/tmp/offline.repo"
  config.vm.provision "shell", path: "script/post-universal.sh"
  #config.vm.provision "shell", path: "script/post-offline.sh"
end
