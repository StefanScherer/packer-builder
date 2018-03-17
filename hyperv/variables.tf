# Settings

variable "resource_group" {
  default = "packer-builder"
}

variable "location" {
  default = "westeurope"
}

variable "name" {
  default = "cirlce1"
}

variable "admin_username" {
  default = "packer"
}

variable "vm_size" {
  default = "Standard_D2_v3"
}

variable "ssh" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgJaXO4kPPAB5ul7Yj+QMV1Vfz5nqoqDs6/l+nv9bpC9vasSAMrktROh/wQctFqB+ZofaCz6hcNwNtVKmYdihTr62Nk5NVRkJTggEnJGZxiy/49ddg+Y5/7IuaRbpmE03UA3ELppWiWGEXaJ4+MrTL86mXwALrrgPb2z0A3JPhHgMiO3p2GBApOzSvhoC6pRHNWcuraR4NEtOmGudKIkUSWyBGp4Nkrf7SOkbhCBSgp1lAmhagcrW2tQRgmNQ1NWFyR+C+ZPPGZ3SWBS9rJoIIYrdFR1DBDNshnWHkSUgR22xFKG5APgEnb2Ec+g1XjJn9QNgdFDoDn/osa8rXY1T3"
}
