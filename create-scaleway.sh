#!/bin/bash
NAME="packer-01"
scw start --wait $(scw create --commercial-type=C2S --name=$NAME Ubuntu_Xenial)
cat scripts/provision-vmware-builder.sh | scw exec $NAME bash
