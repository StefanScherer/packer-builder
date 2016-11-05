# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "vmware", primary: true do |cfg|
    cfg.vm.box = "boxcutter/ubuntu1604"

    cfg.vm.provision "shell", path: "scripts/provision-vmware-builder.sh"
    ["vmware_fusion", "vmware_workstation"].each do |provider|
      cfg.vm.provider provider do |v, override|
        v.vmx["memsize"] = "4096"
        v.vmx["numvcpus"] = "2"
        v.vmx["vhv.enable"] = "TRUE"
      end
    end
  end
end
