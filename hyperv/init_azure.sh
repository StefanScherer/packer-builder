#!/bin/bash
set -e

for i in CIRCLECI_TOKEN
do
  if [ -z "${!i}" ]; then
    echo "Environment variable $i must be set"
    exit 5
  fi
done

location=$(grep -A1 location variables.tf | grep -v location | awk '{gsub(/"/, "", $3); print $3}')
resource_group=$(grep -A1 resource_group variables.tf | grep -v resource_group | awk '{gsub(/"/, "", $3); print $3}')

echo "Creating resource group $resource_group"
scope=$(az group create -n "$resource_group" -l "$location" | jq -r .id)

aadClientName="Terraform-$resource_group"
ARM_CLIENT_SECRET=$(pwgen 30 1)

echo "Creating service principal $aadClientName"

ARM_SUBSCRIPTION_ID=$(az account show | jq -r .id)
ARM_TENANT_ID=$(az account show | jq -r .tenantId)

set +e
aadClientId=$(az ad sp show --id "http://$aadClientName" | jq -r .id)
if [ "$aadClientId" != "" ]; then
  echo "Deleting old service principal $aadClientName"
  az ad sp delete --id "http://$aadClientName"
fi
set -e
ARM_CLIENT_ID=$(az ad sp create-for-rbac -n "$aadClientName" --password "$ARM_CLIENT_SECRET" --role contributor --scopes "$scope" | jq -r .appId)

org=$(git remote get-url origin | sed 's/.*github.com://' | sed 's/.*github.com\///' | sed 's/\.git$//' | sed 's/\/.*$//' )
repo=$(git remote get-url origin | sed 's/.*github.com://' | sed 's/.*github.com\///' | sed 's/\.git$//' | sed 's/.*\///' )

circlevars="
ARM_SUBSCRIPTION_ID
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
"

echo "Deleting CircleCI environment variables for $org/$repo"
for i in $circlevars
do
  curl -X DELETE -sS --fail --header "Content-Type: application/json" "https://circleci.com/api/v1.1/project/github/$org/$repo/envvar/$i?circle-token=$CIRCLECI_TOKEN"  >/dev/null || true
done

echo "Setting CircleCI environment variables for $org/$repo"
for i in $circlevars
do
  curl -X POST -sS --fail --header "Content-Type: application/json" -d "{\"name\":\"${i}\", \"value\":\"${!i}\"}" "https://circleci.com/api/v1.1/project/github/$org/$repo/envvar?circle-token=$CIRCLECI_TOKEN" >/dev/null
done
