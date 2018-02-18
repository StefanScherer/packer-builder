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

set -x
touch $log
only=--only=${HYPERVISOR}-iso

hypervisor1=${HYPERVISOR%+*}
hypervisor2=${HYPERVISOR#*+}

if [ "$hypervisor1" != "$hypervisor2" ]; then
  only="--only=${hypervisor1}-iso --only=${hypervisor2}-iso"
fi
packer build $only --var headless=true "${FILE}.json" | tee -a $log

if [ -e ../packer-upload-and-destroy.sh ]; then
  ../packer-upload-and-destroy.sh
fi
