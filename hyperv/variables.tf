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
  default = "Standard_D2s_v3"
}

variable "ssh" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmRhIcJz+124p+gHv8jhvMq6yBQuEMKUF+Zxdxm6HZl/tnuwlAWGq+rU5C/10MXArauNl3M2sjH8zzbvW6jh4qlsS5Ax62apMuRWiX8XfLx6ssUVh+IfoZJDVbaeJu1jtbQQly+BfYeS5UBFnJlUFLHVVqmWfL44Q5DozvRnU0sYQd+gKjd3ai9By/dZvDaQxmq9tccKmGwVN4vF1S+ZmHK+FluC20k6TR8LN9c70hjTKkK8hEkvxAD/1Aij8RZAmKXXz9Cul3n4rB88XHiDG5gld22UuIGQ3xHqEUhOaSag9Dm+L3mo3xVFVy7IlkrzXqAEsgat5AaQsQrtL7JyPL"
}
