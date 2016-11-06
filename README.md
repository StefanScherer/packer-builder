# Packer Builder

Setup a Packer builder machine for VMware Vagrant boxes.

## Packet.net

Create a baremetal [packet.net](https://packet.net) machine and run Packer there.

First you need the `packet` golang cli:

```bash
go get -u github.com/ebsarr/packet
```

Then use the script `packet.sh` to make things even simpler:

```bash
./packet.sh create packer1
./packet.sh ssh packer1
packer build ...
```

## Vagrant

Create a local VM and run Packer there. This is used to test the
provision script.

```bash
vagrant up
vagrant ssh
packer build ...
```
