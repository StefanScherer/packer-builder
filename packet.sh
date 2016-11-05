#!/bin/bash

COMMAND=$1
NAME=$2
FACILITY=ams1
OSTYPE=ubuntu_14_04
PLAN=baremetal_0
PROJECT=packer

if [ -z "${COMMAND}" ]; then
  echo "Usage:"
  echo "  $0 create name"
  echo "  $0 delete name"
  echo "  $0 list"
  echo "  $0 provision name"
  echo "  $0 ssh name"
  echo "  $0 start name"
  echo "  $0 stop name"
  exit 1
fi

TOKEN=$(pass packet_token)

function provision {
  NAME=$1
  ID=$2

  cat scripts/provision-vmware-builder.sh | /usr/bin/ssh root@$(ip)
}

function create {
  NAME=$1
  ID=$2

  if [ -z "${NAME}" ]; then
    echo "Usage: $0 name"
    exit 1
  fi

  # create project if it does not exist
  if [ -z "${ID}" ]; then
    ID=$(packet -k "${TOKEN}" \
      project create --name "${PROJECT}" | jq -r .id)
  fi

  # create vm
  packet -k "${TOKEN}" device create \
    --facility "${FACILITY}" \
    --os-type "${OSTYPE}" \
    --plan "${PLAN}" \
    --project-id "${ID}" \
    --hostname "${NAME}"

  provision "${NAME}" "${ID}"
}

function cmd {
  NAME=$1
  ID=$2

  if [ -z "${NAME}" ] || [ -z "${ID}" ] || [ -z "${CMD}" ]; then
    echo "Usage: $0 name id command"
    exit 1
  fi

  DEVICEID=$(packet -k "${TOKEN}" \
    device listall --project-id "${ID}" | jq -r ".[] | select(.hostname == \"${NAME}\") .id")

  packet -k "${TOKEN}" \
    device "${CMD}" --device-id "${DEVICEID}"
}

function start {
  cmd "$1" "$2" power-on
}

function stop {
  cmd "$1" "$2" power-off
}

function delete {
  cmd "$1" "$2" delete
}

function list {
  packet -k $(pass packet_token) device listall --project-id $ID | \
    jq -r '.[] | .hostname + "	" + .state'
}

function ip {
  packet -k $(pass packet_token) device listall --project-id $ID | \
    jq -r ".[] | select(.hostname == \"${NAME}\") | .ip_addresses[] | select(.public == true) | select(.address_family == 4).address"
}

function ssh {
  /usr/bin/ssh root@$(ip)
}

ID=$(packet -k "${TOKEN}" \
  project listall | jq -r ".[] | select(.name == \"${PROJECT}\") .id")

"${COMMAND}" "${NAME}" "${ID}"
