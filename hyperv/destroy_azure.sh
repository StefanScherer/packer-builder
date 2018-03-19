#!/bin/bash

resource_group=$(grep -A1 resource_group variables.tf | grep -v resource_group | awk '{gsub(/"/, "", $3); print $3}')

aadClientName="Terraform-$resource_group"
echo "Deleting service principal $aadClientName"
az ad app delete --id http://$aadClientName

echo "Deleting resource group $resource_group"
az group delete -n $resource_group

