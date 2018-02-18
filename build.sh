#!/bin/bash
NAME=$1
FILE=$2
HYPERVISOR=$3

if [ -z "${NAME}" ] || [ "${NAME}" == "--help" ] || [ -z "${FILE}" ]; then
  echo "Usage: $0 machine jobname"
  echo "$0 p1 windows_2016_docker virtualbox|vmware"
  exit 1
fi

ip=$(./packet.sh ip $NAME)
scp packer-build.sh root@$ip:

echo "Monitor the packer build with VNC and SSH"
echo "See the VNC port number and password in packer output."
echo ""
echo "ssh -L 127.0.0.1:5900:127.0.0.1:59xx root@$ip tail -f packer-windows/packer-build.log"

ssh -n -f root@$(./packet.sh ip $NAME) "sh -c 'nohup ./packer-build.sh $FILE $HYPERVISOR > /dev/null 2>&1 &'"

sleep 20

if [ -z "$PACKET_APIKEY" ]; then
  echo "Skip upload"
else
  today=$(date +%Y-%m-%d)
  cat <<CMD >packer-upload-and-destroy.sh
  export PACKET_APIKEY=$PACKET_APIKEY
  export AZURE_STORAGE_ACCOUNT=$AZURE_STORAGE_ACCOUNT
  export AZURE_STORAGE_ACCESS_KEY=$AZURE_STORAGE_ACCESS_KEY
  if [ -e packer-windows/${FILE}_vmware.box ]; then
    azure storage blob upload packer-windows/${FILE}_vmware.box box ${FILE}/$today/${FILE}_vmware.box
  fi
  if [ -e packer-windows/${FILE}_vmware.box ]; then
    azure storage blob upload packer-windows/${FILE}_virtualbox.box box ${FILE}/$today/${FILE}_virtualbox.box
  fi
  packet.sh stop \$(hostname)
CMD
  chmod +x packer-upload-and-destroy.sh
  scp packer-upload-and-destroy.sh root@$ip:
  scp $(which packet) root@$ip:/usr/bin/packet
  scp ./packet.sh root@$ip:/usr/bin/packet.sh
  rm packer-upload-and-destroy.sh
fi

ssh root@$(./packet.sh ip $NAME) tail -f packer-windows/packer-build.log
