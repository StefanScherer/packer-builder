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
packer build --only=${HYPERVISOR}-iso --var headless=true "${FILE}.json" --var iso-url=file:///tmp/local.iso | tee -a $log
