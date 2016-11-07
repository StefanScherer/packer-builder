#!/bin/bash
NAME=$1
FILE=macos1012

if [ -z "${NAME}" ] || [ "${NAME}" == "--help" ] || [ -z "${FILE}" ]; then
  echo "Usage: $0 machine"
  echo "$0 p1"
  exit 1
fi

cat <<CMD | ssh root@$(./packet.sh ip $NAME)
if [ ! -d macos ]; then
  git clone https://github.com/boxcutter/macos
fi
cd macos
if [ ! -d dmg ]; then
  mkdir dmg
  curl -o dmg/OSX_InstallESD_10.12_16A323.dmg https://vagrantboxes.blob.core.windows.net/box/macOS/dmg/OSX_InstallESD_10.12_16A323.dmg
fi
git checkout -- *.json
git pull
rm -f *.box
rm -rf output*
sed -i '/"ssh_port"/ a\
      "headless": true,' macos.json
packer build -only=vmware-iso -var-file=${FILE}.json macos.json
CMD
