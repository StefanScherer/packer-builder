# Configure the Microsoft Azure Provider
provider "azurerm" {
  version = "= 1.25.0"
}

provider "random" {
  version = "~> 1.1"
}

resource "random_string" "password" {
  length = 16
  special = false
}

# Create a storage account
resource "azurerm_storage_account" "global" {
  account_tier             = "Premium"                          # Only locally redundant
  account_replication_type = "LRS"
  location                 = "${var.location}"
  name                     = "${var.name}"
  resource_group_name      = "${var.resource_group}"
}

resource "azurerm_virtual_network" "windows" {
    name = "virtnet-${var.name}"
    address_space = ["10.0.0.0/16"]
    location = "${var.location}"
    resource_group_name = "${var.resource_group}"
}

resource "azurerm_subnet" "windows" {
    name = "subnet-${var.name}"
    resource_group_name = "${var.resource_group}"
    virtual_network_name = "${azurerm_virtual_network.windows.name}"
    address_prefix = "10.0.2.0/24"
}

resource "azurerm_network_interface" "windows" {
    name = "nic-${var.name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group}"

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = "${azurerm_subnet.windows.id}"
        public_ip_address_id          = "${azurerm_public_ip.windows.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_public_ip" "windows" {
  idle_timeout_in_minutes = 30
  location                = "${var.location}"
  name                    = "pubip-${var.name}"
  allocation_method       = "Dynamic"
  resource_group_name     = "${var.resource_group}"
}

resource "azurerm_storage_container" "windows" {
  container_access_type = "private"
  name                  = "windows-storage"
  resource_group_name   = "${var.resource_group}"
  storage_account_name  = "${azurerm_storage_account.global.name}"
}

resource "azurerm_virtual_machine" "windows" {
    name = "vm-${var.name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group}"
    network_interface_ids = ["${azurerm_network_interface.windows.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2019-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "osdisk-${var.name}"
        vhd_uri = "${azurerm_storage_container.windows.id}/disk1.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.name}"
        admin_username = "${var.admin_username}"
        admin_password = "${random_string.password.result}"
        custom_data = "${base64encode("Param($Username=\"${var.admin_username}\", $Password=\"${random_string.password.result}\", $sshKey=\"${var.ssh}\") ${file("./provision.ps1")}")}"
    }

    os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = true
        additional_unattend_config {
            pass = "oobeSystem"
            component = "Microsoft-Windows-Shell-Setup"
            setting_name = "AutoLogon"
            content = "<AutoLogon><Password><Value>${random_string.password.result}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
        }
        additional_unattend_config {
            pass = "oobeSystem"
            component = "Microsoft-Windows-Shell-Setup"
            setting_name = "FirstLogonCommands"
            content = "${file("./FirstLogonCommands.xml")}"
        }
    }

    tags {
        environment = "staging"
    }
}

output "ip" {
  value = "${azurerm_public_ip.windows.ip_address}"
}
