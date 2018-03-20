# Packer Hyper-V builder in Azure

This is a Terraform template to spin up a VM in Azure that has nested Hyper-V
activated and tools like Git, Packer and Vagrant installed.

Now you are able to build Vagrant base boxes for Hyper-V in the Cloud with Packer.

## Initialize Azure and CircleCI

You need a personal API key for CircleCI. Set the environment variable `CIRCLECI_TOKEN`
and run the script

```
./init_azure.sh
```

It will create a resource group and service principal and set `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET` and `ARM_TENANT_ID` in CircleCI.

## Destroy Azure

If you want to clean up your Azure subscription run

```
./destroy_azure.sh
```

It will remove the resource group and service princial and app from Azure.

## Spin up the Azure VM with Terraform from local machine

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

For Terraform you will need these environment variables

```
export ARM_SUBSCRIPTION_ID="uuid"
export ARM_CLIENT_ID="uuid"
export ARM_CLIENT_SECRET="secret"
export ARM_TENANT_ID="uuid"
```

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
