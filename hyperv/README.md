# Packer Hyper-V builder in Azure

This is a Terraform template to spin up a VM in Azure that has nested Hyper-V
activated and tools like Git, Packer and Vagrant installed.

Now you are able to build Vagrant base boxes for Hyper-V in the Cloud with Packer.

## Stage 1: Spin up the Azure VM with Terraform

### Install Terraform

```
brew install terraform
```

### Configure

Adjust the file `variables.tf` to your needs to choose

* location / region
* resource group name
* DNS prefix and suffix
* size of the VM's, default is `Standard_E2s_v3` which is needed for nested virtualization
* username and password

### Secrets

Get your Azure ID's and secret with `pass`

```
eval $(pass azure-terraform)
```

You will need these environment variables for terraform

```
export ARM_SUBSCRIPTION_ID="uuid"
export ARM_CLIENT_ID="uuid"
export ARM_CLIENT_SECRET="secret"
export ARM_TENANT_ID="uuid"
```

You can adjust location and resource_group in `variables.tf` and then run
the script `./init_azure.sh` to create a service principal for Terraform
that has access to the resource group.

### Plan

```bash
terraform plan
```

### Create / Apply

Create the Azure VM with. After 5 minutes the VM should be up and running, and the provision.ps1 script will run inside the VM to install Packer, Vagrant, Hyper-V and then reboots the VM and adds the internal virtual switch 'packer-hyperv-iso' and DHCP server.

```bash
terraform apply
```

If you want more than one Packer VM, then use eg. `terraform apply -var name=circle123`.
