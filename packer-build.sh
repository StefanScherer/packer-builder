#!/bin/bash
FILE=$1
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
packer build --only=vmware-iso --var headless=true "${FILE}.json" | tee -a $log
