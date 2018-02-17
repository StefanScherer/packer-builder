#!/bin/bash

PACKER_VERSION=1.1.3
VIRTUALBOX_VERSION=5.2

PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

sudo apt-get update -qq

# install VirtualBox and other tools
sudo apt-get install -qq git unzip curl nodejs virtualbox-${VIRTUALBOX_VERSION} dkms build-essential

# install packer
mkdir /opt/packer
pushd /opt/packer
echo "Downloading packer ${PACKER_VERSION} ...."
curl -L -o ${PACKER_VERSION}_linux_amd64.zip ${PACKER_URL}
echo "Installing packer ${PACKER_VERSION} ..."
unzip ${PACKER_VERSION}_linux_amd64.zip
rm ${PACKER_VERSION}_linux_amd64.zip
pushd /usr/bin
ln -s /opt/packer/* .
popd
popd

echo "Installing azure cli ..."
npm install -g azure-cli
