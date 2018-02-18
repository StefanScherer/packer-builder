#!/bin/bash
FILE=$1
HYPERVISOR=$2
if [ ! -d packer-windows ]; then
  git clone https://github.com/StefanScherer/packer-windows
fi
cd packer-windows
git checkout -- *.json
git pull
rm -f *.box
rm -rf output*
log=packer-build.log

touch $log
only=--only=${HYPERVISOR-iso}
if [ "${HYPERVISOR}" == "virtualbox+vmware" ]; then
  only=--only=virtualbox-iso --only=vmware-iso
fi
packer build $only --var headless=true "${FILE}.json" | tee -a $log

if [ -e ../packer-upload-and-destroy.sh ]; then
  ../packer-upload-and-destroy.sh
fi
