#!/bin/bash
FILE=$1
HYPERVISOR=$2
GITHUB_URL=$3
ISO_URL=$4

log=packer-build.log
echo $0 $* >> $log

if [ ! -d work ]; then
  echo "Cloning $GITHUB_URL" >> $log
  git clone $GITHUB_URL work
fi
cd work
touch $log
git checkout -- *.json
git pull
rm -f *.box
rm -rf output*

isoflag=""
if [ -z "${ISO_URL}" ]; then
  echo "Use default ISO." >> $log
else
  echo "Use local ISO." >> $log
  if [ ! -e local.iso ]; then
    echo "Downloading ISO ..." >> $log
    curl -Lo local.iso $ISO_URL
  fi
  isoflag="--var iso_url=./local.iso"
fi

only=--only=${HYPERVISOR}-iso
hypervisor1=${HYPERVISOR%+*}
hypervisor2=${HYPERVISOR#*+}
if [ "$hypervisor1" != "$hypervisor2" ]; then
  only="--only=${hypervisor1}-iso --only=${hypervisor2}-iso"
fi
echo Running packer build $only $isoflag --var headless=true "${FILE}.json" >> $log
echo "" >> $log
ls -l local.iso >> $log
echo "" >> $log
packer build $only $isoflag --var headless=true "${FILE}.json" | tee -a $log

if [ ! -e ../packer-upload-and-destroy.sh ]; then
  sleep 30
fi

if [ -e ../packer-upload-and-destroy.sh ]; then
  ../packer-upload-and-destroy.sh | tee -a $log
fi
