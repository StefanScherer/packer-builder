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
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC87nvCwiQHNYpCP+20Sk6VDpmAzHU61qkihOXZm5X98iGQU/lxBzFCYIlsIUzfdDZAEB8xjEuuNjR4AXBB0SWD67C6ez40keGe0xo7dYRaMRM/p4wU8WYedxU9y7KLWU3MK+6K8EtJUTqkVQ/OGzViAEfTACheJRwsCdu7LWju1XjeK/SdFijRoN8FE2UModLyUnwdgTQNc6xQZq0Qz+Yt9EpHeNI8MgezXb+lGWJ/OAoPg5uqpAyfBZwlo2r+efKmSdY/48T3gIZxkHdatTZ2qbQ7DZef/7nYz+TH957LxepdPawLWngtYBUuDbvV3bBudaKtQc2oGbvuz3YRmWNN"
}
