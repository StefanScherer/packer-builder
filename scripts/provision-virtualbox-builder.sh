#!/bin/bash

PACKER_VERSION=1.2.5
VIRTUALBOX_VERSION=5.2

PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip

# Install Virtualbox 5.2
echo "deb http://download.virtualbox.org/virtualbox/debian bionic contrib" >> /etc/apt/sources.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get update
sudo apt-get install -qq git unzip curl nodejs virtualbox-${VIRTUALBOX_VERSION} dkms build-essential psmisc

# Install VirtualBox extension pack
vbox=$(VBoxManage --version)
vboxversion=${vbox%r*}
vboxrevision=${vbox#*r}
wget https://download.virtualbox.org/virtualbox/${vboxversion}/Oracle_VM_VirtualBox_Extension_Pack-${vboxversion}-${vboxrevision}.vbox-extpack
yes | VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-${vboxversion}-${vboxrevision}.vbox-extpack
rm Oracle_VM_VirtualBox_Extension_Pack-${vboxversion}-${vboxrevision}.vbox-extpack

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
