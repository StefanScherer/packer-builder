#!/bin/bash

PACKER_VERSION=0.10.2
VMWARE_VERSION=12.5.1-4542065

apt-get update
apt-get install -qq git unzip curl

# install packer
mkdir /opt/packer
pushd /opt/packer
echo "Downloading packer ${PACKER_VERSION} ...."
curl -L -o ${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
echo "Installing packer ${PACKER_VERSION} ..."
unzip ${PACKER_VERSION}_linux_amd64.zip
rm ${PACKER_VERSION}_linux_amd64.zip
pushd /usr/bin
ln -s /opt/packer/* .
popd

apt-get install -qq linux-headers-$(uname -r)
apt-get install -qq dkms
apt-get install -qq x11-common x11-xserver-utils libxtst6 libxinerama1

rmmod kvm_intel kvm

echo "Downloading VMware Workstation ${VMWARE_VERSION} ..."
curl -o VMware-Workstation.bundle https://download3.vmware.com/software/wkst/file/VMware-Workstation-Full-${VMWARE_VERSION}.x86_64.bundle
echo "Installing VMware Workstation ${VMWARE_VERSION} ..."
sh ./VMware-Workstation.bundle --console --required --eulas-agreed
rm ./VMware-Workstation.bundle
