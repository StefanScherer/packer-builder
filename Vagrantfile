# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "vmware", primary: true do |cfg|
    cfg.vm.box = "bento/ubuntu-19.10"
    cfg.vm.synced_folder "/Users/stefan/packer_cache", "/home/vagrant/packer_cache"

    cfg.vm.provision "shell", path: "scripts/provision-virtualbox+vmware-builder.sh"
    cfg.vm.provider "vmware_desktop" do |v, override|
      v.vmx["memsize"] = "6196"
      v.vmx["numvcpus"] = "4"
      v.vmx["vhv.enable"] = "TRUE"
      v.gui = true
    end
  end
end
