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
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDm3bZwzpnjklKH7D/w7a83pzqdvB340dBhQuOmpLszs0H+Js505zZWX3nb0OSFMJ6LjPHZBL9OTj6B+sWxj95QrUTonHso2Jb2bhe8UYwmqvKpmMHIjIjl4UV73tN4VJSWtBaxNdG7KYnpv0dyZu1JitR72+qRUohbzkUbVLQUQ/LE8LJI5ob0VK9EdFXl249gSgYOp4G6Tocy5aVYJAR80bC7Ujrn4tLB0dzBERNQjPrR5JHQ7OlFcaI0ho9zVy+GziU++vNols/Dl0TkvHJKxNE1XQTWAHj1YjVzTMfDlc2M9uoeY/GLXxlkPMskoKbopB1ZvAFGLP2ldUfQ7NA3"
}
