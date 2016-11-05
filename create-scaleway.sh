#!/bin/bash
name=$1

scw create --commercial-type=C2S --name=${name} Ubuntu_Xenial
sleep 15
scw start -w ${name}
cat scripts/provision-vmware-builder.sh | scw exec ${name} bash
