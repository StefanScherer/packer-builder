# Packer Builder

[![CircleCI](https://circleci.com/gh/StefanScherer/packer-builder.svg?style=svg)](https://circleci.com/gh/StefanScherer/packer-builder)

Setup a Packer builder machine for VirtualBox and VMware Vagrant boxes.

## Packet.net

Create a baremetal [packet.net](https://packet.net) machine and run Packer there.

First you need the `packet` golang cli:

```bash
go get -u github.com/ebsarr/packet
```

Then use the script `packet.sh` to make things even simpler:

```bash
./packet.sh create p1
```

And then build a VMware VM

```bash
./build.sh p1 windows_2016_docker vmware|virtualbox
./packet.sh photo p1
./upload.sh p1 windows_2016_docker
```

Afterwards remove the baremetal machine again

```bash
./packet.sh delete p1
```

There are several other commands in `packet.sh`. Have a look at the usage.

## Vagrant

Create a local VM and run Packer there. This is used to test the
provision script.

```bash
vagrant up
vagrant ssh
packer build ...
```
