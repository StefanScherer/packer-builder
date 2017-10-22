# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "vmware", primary: true do |cfg|
    cfg.vm.box = "bento/ubuntu-16.04"
    cfg.vm.synced_folder "/Users/stefan/packer_cache", "/home/vagrant/packer_cache"

    cfg.vm.provision "shell", path: "scripts/provision-vmware-builder.sh"
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      cfg.vm.provider provider do |v, override|
        v.vmx["memsize"] = "6196"
        v.vmx["numvcpus"] = "4"
        v.vmx["vhv.enable"] = "TRUE"
      end
    end
  end
end
