# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "chef/centos-6.5-i386"

  
  config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  
  config.vm.define "web" do |web|
    web.vm.provision :shell, :path => "bootstrapWeb.sh"
    web.vm.hostname = "web"
    web.vm.network "private_network", ip: "192.168.100.10"
    web.vm.network "public_network", ip: "192.168.1.200"
  end

  config.vm.define "db" do |db|
    db.vm.provision :shell, :path => "bootstrapDb.sh"
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: "192.168.100.11"
    db.vm.network "public_network", ip: "192.168.1.201"
  end
end
