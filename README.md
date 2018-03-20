# Packer Builder

[![CircleCI](https://circleci.com/gh/StefanScherer/packer-builder.svg?style=svg)](https://circleci.com/gh/StefanScherer/packer-builder)

Setup a Packer builder machine for VirtualBox and VMware Vagrant boxes.

## Packet.net

Create a baremetal [packet.net](https://packet.net) machine and run Packer there.

First you need the `packet` golang cli:

```bash
go get -u github.com/ebsarr/packet
```

Then use the script `machine.sh` to make things even simpler:

```bash
./machine.sh create p1
```

And then build a VMware VM

```bash
./build.sh p1 windows_2016_docker vmware|virtualbox
```

Afterwards remove the baremetal machine again

```bash
./machine.sh delete p1
```

There are several other commands in `machine.sh`. Have a look at the usage.

## Vagrant

Create a local VM and run Packer there. This is used to test the
provision script.

```bash
vagrant up
vagrant ssh
packer build ...
```

## Configuration

### CircleCI Environment Variables

* AZURE_STORAGE_ACCESS_KEY
* AZURE_STORAGE_ACCOUNT
* AZURE_STORAGE_CONTAINER
* PACKET_APIKEY
* VAGRANT_CLOUD_TOKEN
* VAGRANT_CLOUD_USER
* windows_server_xxx_docker
