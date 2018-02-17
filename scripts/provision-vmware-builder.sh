#!/bin/bash

PACKER_VERSION=1.1.3
VMWARE_VERSION=14.1.1-7528167

PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
VMWARE_URL=http://download3.vmware.com/software/wkst/file/VMware-Workstation-Full-${VMWARE_VERSION}.x86_64.bundle

apt-get update
apt-get install -qq git unzip curl

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

apt-get install -qq linux-headers-$(uname -r)
apt-get install -qq dkms
apt-get install -qq x11-common x11-xserver-utils libxtst6 libxinerama1

rmmod kvm_intel kvm

echo "Downloading VMware Workstation ${VMWARE_VERSION} ..."
curl -o VMware-Workstation.bundle ${VMWARE_URL}
echo "Installing VMware Workstation ${VMWARE_VERSION} ..."
sh ./VMware-Workstation.bundle --console --required --eulas-agreed
rm ./VMware-Workstation.bundle

echo "Downloading vncsnapshot ..."
curl -o vncsnapshot.tar.gz https://netcologne.dl.sourceforge.net/project/vncsnapshot/vncsnapshot/1.2a/vncsnapshot-1.2a-Linux-x86.tar.gz
tar xzvf vncsnapshot.tar.gz
mv vncsnapshot-1.2a/bin/* /usr/bin
chmod 755 /usr/bin/vncsnapshot

cat <<'PHOTO' > /usr/bin/photo
#!/bin/bash
filename=${1:-snapshot.jpg}
pass=$(cat $(ps wwaux | grep -v grep | grep .vmx | awk '{print $NF}') | grep vnc.password | sed 's/.* = "//' | sed 's/"$//')
echo "$pass" > /tmp/passwd.txt
vncsnapshot -allowblank -passwd /tmp/passwd.txt 127.0.0.1:$(cat $(ps wwaux | grep -v grep | grep .vmx | awk '{print $NF}') | grep vnc.port | sed 's/.*"59//' | sed 's/"//')
PHOTO
chmod +x /usr/bin/photo

echo "Installing azure cli ..."
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g azure-cli
