#!/bin/bash
NAME=$1
FILE=$2

if [ -z "${NAME}" ] || [ "${NAME}" == "--help" ] || [ -z "${FILE}" ]; then
  echo "Usage: $0 machine jobname"
  echo "$0 p1 windows_2016_docker"
  exit 1
fi

cat <<CMD | scw exec $NAME bash
if [ ! -d packer-windows ]; then
  git clone https://github.com/StefanScherer/packer-windows
fi
cd packer-windows
git checkout -- *.json
git pull
rm *.box
rm -rf output*
sed -i -e 's/"headless": false/"headless": true/' "${FILE}.json"
export PACKER_LOG=1
packer build --only=vmware-iso "${FILE}.json"
CMD
