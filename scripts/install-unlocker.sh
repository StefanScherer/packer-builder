#!/bin/bash
curl -o unlocker208.tar.gz https://vagrantboxes.blob.core.windows.net/box/macOS/unlocker208.tar.gz
tar xzvf unlocker208.tar.gz
cd unlocker208
sed -i -e "s/vmx_version = .*/vmx_version = 'VMware Player 12'/" unlocker.py
echo "Stopping VMware"
/etc/init.d/vmware stop
/etc/init.d/vmware-USBArbitrator stop
/etc/init.d/vmware-workstation-server stop
echo "Patching VMware"
./lnx-install.sh
echo "Starting VMware"
/etc/init.d/vmware start
/etc/init.d/vmware-USBArbitrator start
/etc/init.d/vmware-workstation-server start
