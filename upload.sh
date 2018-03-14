#!/bin/bash
set -e

FILE=$1
HYPERVISOR=$2

if [ -z "${FILE}" ] || [ "${FILE}" == "--help" ] || [ -z "${HYPERVISOR}" ]; then
  echo "Usage: $0 template hypervisor"
  echo "$0 windows_2016_docker vmware"
  exit 1
fi

function upload {
  FILE=$1
  BOX_VERSION=$2
  HYPERVISOR=$3

  echo "Create a new provider $HYPERVISOR for version $BOX_VERSION"
  curl \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    "https://app.vagrantup.com/api/v1/box/$VAGRANT_CLOUD_USER/$FILE/version/$BOX_VERSION/providers" \
    --data "{ \"provider\": { \"name\": \"$HYPERVISOR\" } }"

  echo "Prepare the provider for upload/get an upload URL"
  response=$(curl \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    "https://app.vagrantup.com/api/v1/box/$VAGRANT_CLOUD_USER/$FILE/version/$BOX_VERSION/provider/$HYPERVISOR/upload")

  # Extract the upload URL from the response (requires the jq command)
  upload_path=$(echo "$response" | jq .upload_path)

  echo "Upload ${FILE}_${HYPERVISOR}.box to Vagrant Cloud"
  curl $upload_path --request PUT --upload-file "${FILE}_${HYPERVISOR}.box"
  
  rm "${FILE}_${HYPERVISOR}.box"
}

function download {
  FILE=$1
  HYPERVISOR=$2
  echo "Download box ${FILE}_${HYPERVISOR}.box"
  today=$(date +%Y-%m-%d)
  set +e
  az storage blob download --container-name "${AZURE_STORAGE_CONTAINER}" --name "${FILE}/$today/${FILE}_${HYPERVISOR}.box" --file "${FILE}_${HYPERVISOR}.box"
  set -e

  if [ ! -e "${FILE}_${HYPERVISOR}.box" ]; then
    yesterday=$(date -d "yesterday 13:00" +%Y-%m-%d)
    az storage blob download --container-name "${AZURE_STORAGE_CONTAINER}" --name "${FILE}/$yesterday/${FILE}_${HYPERVISOR}.box" --file "${FILE}_${HYPERVISOR}.box"
  fi  
}

BOX_VERSION="v$(date +%Y.%m.%d)"
echo "Create a new version $BOX_VERSION for $FILE in Vagrant Cloud"
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  "https://app.vagrantup.com/api/v1/box/$VAGRANT_CLOUD_USER/$FILE/versions" \
  --data "{ \"version\": { \"version\": \"$BOX_VERSION\" } }"

hypervisor1=${HYPERVISOR%+*}
hypervisor2=${HYPERVISOR#*+}

download "$FILE" "$hypervisor1"
upload "$FILE" "$BOX_VERSION" "$hypervisor1"

if [ "$hypervisor1" != "$hypervisor2" ]; then
  download "$FILE" "$hypervisor2"
  upload "$FILE" "$BOX_VERSION" "$hypervisor2"
fi
