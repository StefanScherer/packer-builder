#!/bin/bash
set -e

FILE=$1
HYPERVISOR=$2

if [ -z "${FILE}" ] || [ "${FILE}" == "--help" ] || [ -z "${HYPERVISOR}" ]; then
  echo "Usage: $0 template hypervisor"
  echo "$0 windows_2019_docker vmware"
  exit 1
fi

function upload {
  FILE=$1
  BOX_VERSION=$2
  HYPERVISOR=$3

  VAGRANT_PROVIDER="$HYPERVISOR"
  if [ "$HYPERVISOR" == "vmware" ]; then
    VAGRANT_PROVIDER="${HYPERVISOR}_desktop"
  fi

  echo "Create a new provider $VAGRANT_PROVIDER for version $BOX_VERSION"
  curl \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    "https://app.vagrantup.com/api/v1/box/$VAGRANT_CLOUD_USER/$FILE/version/$BOX_VERSION/providers" \
    --data "{ \"provider\": { \"name\": \"$VAGRANT_PROVIDER\" } }"

  echo "Prepare the provider for upload/get an upload URL"
  response=$(curl \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    "https://app.vagrantup.com/api/v1/box/$VAGRANT_CLOUD_USER/$FILE/version/$BOX_VERSION/provider/$VAGRANT_PROVIDER/upload")

  # Extract the upload URL from the response (requires the jq command)
  upload_path=$(echo "$response" | jq -r .upload_path)

  echo "Upload ${FILE}_${HYPERVISOR}.box to Vagrant Cloud"
  set +e
  output=$(curl $upload_path --request PUT --upload-file "${FILE}_${HYPERVISOR}.box")
  stat=$?
  if [ "$stat" == "52" ]; then
    echo "Got curl status 52, ignoring for now."
  fi
  set -e
  
  rm "${FILE}_${HYPERVISOR}.box"
}

function download {
  FILE=$1
  HYPERVISOR=$2
  echo "Download box ${FILE}_${HYPERVISOR}.box"
  today=$(date +%Y-%m-%d)
  az storage blob download --account-name "${AZURE_STORAGE_ACCOUNT}" --account-key "${AZURE_STORAGE_ACCESS_KEY}" --container-name "${AZURE_STORAGE_CONTAINER}" --name "${FILE}/$today/${FILE}_${HYPERVISOR}.box" --file "${FILE}_${HYPERVISOR}.box" || true

  if [ ! -e "${FILE}_${HYPERVISOR}.box" ]; then
    yesterday=$(date -d "yesterday 13:00" +%Y-%m-%d)
    az storage blob download --account-name "${AZURE_STORAGE_ACCOUNT}" --account-key "${AZURE_STORAGE_ACCESS_KEY}" --container-name "${AZURE_STORAGE_CONTAINER}" --name "${FILE}/$yesterday/${FILE}_${HYPERVISOR}.box" --file "${FILE}_${HYPERVISOR}.box" || true
  fi  

  if [ ! -e "${FILE}_${HYPERVISOR}.box" ]; then
    twodaysago=$(date -d "2 days ago 13:00" +%Y-%m-%d)
    az storage blob download --account-name "${AZURE_STORAGE_ACCOUNT}" --account-key "${AZURE_STORAGE_ACCESS_KEY}" --container-name "${AZURE_STORAGE_CONTAINER}" --name "${FILE}/$twodaysago/${FILE}_${HYPERVISOR}.box" --file "${FILE}_${HYPERVISOR}.box"
  fi  
}

BOX_VERSION=$(date +%Y.%m.%d)
echo "Create a new version $BOX_VERSION for $FILE in Vagrant Cloud"
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  "https://app.vagrantup.com/api/v1/box/$VAGRANT_CLOUD_USER/$FILE/versions" \
  --data "{ \"version\": { \"version\": \"$BOX_VERSION\" } }"

hypervisor1=${HYPERVISOR%+*}
hypervisor2=${HYPERVISOR#*+}

echo "Login to Azure"
export AZURE_STORAGE_ACCOUNT=$AZURE_STORAGE_ACCOUNT
export AZURE_STORAGE_ACCESS_KEY=$AZURE_STORAGE_ACCESS_KEY

export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
export ARM_CLIENT_ID=$ARM_CLIENT_ID
export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
export ARM_TENANT_ID=$ARM_TENANT_ID

az login --service-principal --username "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}" >az-login.txt

download "$FILE" "$hypervisor1"
upload "$FILE" "$BOX_VERSION" "$hypervisor1"

if [ "$hypervisor1" != "$hypervisor2" ]; then
  download "$FILE" "$hypervisor2"
  upload "$FILE" "$BOX_VERSION" "$hypervisor2"
fi
