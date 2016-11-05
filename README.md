# Packer Builder

Setup a Packer builder machine for VMware Vagrant boxes.

## Scaleway

Create a baremetal Scaleway machine and run Packer there.

```bash
./create-scaleway.sh packer
scw exec packer
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
