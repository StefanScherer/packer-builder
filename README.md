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
./packet.sh create p1
./packet.sh ssh p1
```

And then build a VMware VM

```bash
./build.sh p1 windows_2016_docker
./packet.sh photo p1
./upload.sh p1 windows_2016_docker
```

Afterwards remove the baremetal machine again

```bash
./packet.sh delete p1
```

## Vagrant

Create a local VM and run Packer there. This is used to test the
provision script.

```bash
vagrant up
vagrant ssh
packer build ...
```
