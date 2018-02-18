#!/bin/bash
FILE=$1
HYPERVISOR=$2
GITHUB_URL=$3
ISO_URL=$4

log=packer-build.log
touch $log

if [ ! -d work ]; then
  echo Cloning $GITHUB_URL >> $log
  git clone $GITHUB_URL work
fi
cd work
git checkout -- *.json
git pull
rm -f *.box
rm -rf output*

if [ -z "${ISO_URL}" ]; then
  echo Use default ISO. >> $log
else
  echo Use local ISO. >> $log
  curl -Lo local.iso $ISO_URL
  isoflag=--var iso_url=./local.iso
fi

only=--only=${HYPERVISOR}-iso
hypervisor1=${HYPERVISOR%+*}
hypervisor2=${HYPERVISOR#*+}
if [ "$hypervisor1" != "$hypervisor2" ]; then
  only="--only=${hypervisor1}-iso --only=${hypervisor2}-iso"
fi
echo Running packer build $only --var headless=true "${FILE}.json" >> $log
echo "" >> $log
packer build $only $isoflag --var headless=true "${FILE}.json" | tee -a $log

if [ -e ../packer-upload-and-destroy.sh ]; then
  ../packer-upload-and-destroy.sh | tee -a $log
fi
