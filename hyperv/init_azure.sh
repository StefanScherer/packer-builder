#!/bin/bash

location=$(grep -A1 location variables.tf | grep -v location | awk '{gsub(/"/, "", $3); print $3}')
resource_group=$(grep -A1 resource_group variables.tf | grep -v resource_group | awk '{gsub(/"/, "", $3); print $3}')

echo "Creating resource group $resource_group"
scope=$(az group create -n $resource_group -l "$location" | jq -r .id)

aadClientName="Terraform-$resource_group"
aadClientSecret=$(pwgen 30 1)

echo "Creating service principal $aadClientName"
aadClientId=$(az ad sp create-for-rbac -n $aadClientName --password $aadClientSecret --role contributor --scopes "$scope" | jq -r .appId)

subscription_id=$(az account show | jq -r .id)
tenant_id=$(az account show | jq -r .tenantId)

echo "Set these variables in CircleCI or save it in 'pass':"
echo "export ARM_SUBSCRIPTION_ID=\"$subscription_id\""
echo "export ARM_CLIENT_ID=\"$aadClientId\""
echo "export ARM_CLIENT_SECRET=\"$aadClientSecret\""
echo "export ARM_TENANT_ID=\"$tenant_id\""
