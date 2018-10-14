#!/bin/bash

echo "Running provision-virtualbox+vmware-builder.sh"

PACKER_VERSION=1.3.1
VMWARE_VERSION=15.0.0-10134415
VIRTUALBOX_VERSION=5.2

PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
VMWARE_URL=http://download3.vmware.com/software/wkst/file/VMware-Workstation-Full-${VMWARE_VERSION}.x86_64.bundle

# Install Virtualbox 5.2
echo "deb http://download.virtualbox.org/virtualbox/debian bionic contrib" >> /etc/apt/sources.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
apt-get update
sudo apt-get install -qq git unzip curl nodejs dkms build-essential \
                    linux-headers-$(uname -r) x11-common x11-xserver-utils libxtst6 libxinerama1 psmisc

sudo apt-get install -qq virtualbox-${VIRTUALBOX_VERSION}
if ! command -v VBoxManage > /dev/null 2>&1; then
  echo "Manually download VirtualBox 5.2.18"
  wget https://download.virtualbox.org/virtualbox/5.2.18/virtualbox-5.2_5.2.18-124319~Ubuntu~bionic_amd64.deb
  sudo dpkg -i virtualbox-5.2_5.2.18-124319~Ubuntu~bionic_amd64.deb
  sudo apt --fix-broken install -y
fi

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

rmmod kvm_intel kvm

echo "Downloading VMware Workstation ${VMWARE_VERSION} ..."
curl -o VMware-Workstation.bundle ${VMWARE_URL}
echo "Installing VMware Workstation ${VMWARE_VERSION} ..."
sh ./VMware-Workstation.bundle --console --required --eulas-agreed
rm ./VMware-Workstation.bundle

echo "Installing azure cli ..."
npm install -g azure-cli
