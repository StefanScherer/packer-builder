#!/bin/bash

COMMAND=$1
NAME=$2
HYPERVISOR=$3

FACILITY=${PACKET_FACILITY:-ams1}
OSTYPE=ubuntu_18_04
PACKET_PLAN=${PACKET_PLAN:-baremetal_0}
PROJECT=${PACKET_PROJECT:-packer}
AZURE_PLAN=${AZURE_PLAN:-Standard_D2s_v3}

if [ -z "${COMMAND}" ] || [ "${COMMAND}" == "--help" ] ; then
  echo "Usage:"
  echo "  $0 create name type     create a new machine with vmware|virtualbox"
  echo "  $0 delete name          delete a machine"
  echo "  $0 ip name              get IP address of a machine"
  echo "  $0 list                 list all machines"
  echo "  $0 provision name type  provision the machine with vmware|virtualbox"
  echo "  $0 ssh name             ssh into a machine"
  echo "  $0 start name           start a machine"
  echo "  $0 stop name            stop a machine"
  exit 1
fi

TOKEN=${PACKET_APIKEY}

if [ -z "${TOKEN}" ]; then
  TOKEN=$(pass packet_token)
fi

function create {
  NAME=$1
  PROJECTID=$2
  HYPERVISOR=$3

  if [ -z "${NAME}" ]; then
    echo "Usage: $0 name"
    exit 1
  fi

  # create project if it does not exist
  if [ -z "${PROJECTID}" ]; then
    PROJECTID=$(packet -k "${TOKEN}" \
      admin create-project --name "${PROJECT}" | jq -r .id)
  fi

  # create machine
  packet -k "${TOKEN}" baremetal create-device \
    --billing hourly \
    --facility "${FACILITY}" \
    --os-type "${OSTYPE}" \
    --plan "${PACKET_PLAN}" \
    --project-id "${PROJECTID}" \
    --hostname "${NAME}"
    
  echo $?

  provision "${NAME}" "${PROJECTID}" "${HYPERVISOR}"
}

function cmd {
  NAME=$1
  PROJECTID=$2
  CMD=$3

  if [ -z "${NAME}" ] || [ -z "${PROJECTID}" ] || [ -z "${CMD}" ]; then
    echo "Usage: $0 name id command"
    exit 1
  fi

  DEVICEID=$(packet -k "${TOKEN}" \
    baremetal list-devices --project-id "${PROJECTID}" | jq -r ".[] | select(.hostname == \"${NAME}\") .id")

  packet -k "${TOKEN}" \
    baremetal "${CMD}" --device-id "${DEVICEID}"
}

function start {
  echo "Starting $1"
  cmd "$1" "$2" poweron-device
}

function stop {
  echo "Stopping $1"
  cmd "$1" "$2" poweroff-device
}

function delete {
  echo "Deleting $1"
  cmd "$1" "$2" delete-device
}

function list {
  packet -k "${TOKEN}" baremetal list-devices --project-id "${PROJECTID}" | \
    jq -r '.[] | .hostname + "	" + .state'
}

function ip {
  packet -k "${TOKEN}" baremetal list-devices --project-id "${PROJECTID}" | \
    jq -r ".[] | select(.hostname == \"${NAME}\") | .ip_addresses[] | select(.public == true) | select(.address_family == 4).address" | head -1
}

function provision {
  echo "Provisioning $1"
  IP=$(ip)
  ssh-keygen -R "${IP}"
  ssh-keyscan "${IP}" >>~/.ssh/known_hosts
  /usr/bin/ssh "root@${IP}" < "scripts/provision-${HYPERVISOR}-builder.sh"
}

function ssh {
  /usr/bin/ssh "root@$(ip)"
}

function azure_create {
  NAME=$1
  HYPERVISOR=$2

  cd hyperv
  terraform init -input=false
  echo "Running Terraform to build VM ${NAME}"
  terraform apply -input=false -auto-approve --var "name=${NAME}" --var "vm_size=${AZURE_PLAN}"

  echo "Refreshing Terraform state"
  terraform refresh -input=false | grep -vi password

  IP=$(terraform output ip)
  if [ -z "$IP" ]; then
    echo "Waiting for IP"
    sleep 60
    IP=$(terraform output ip)
  fi
  
  echo "IP address of Azure VM $NAME: $IP"

  echo "Wait until SSH is available"
  maxConnectionAttempts=30
  sleepSeconds=20
  index=1
  success=0

  while (( index <= maxConnectionAttempts ))
  do
    /usr/bin/ssh -o StrictHostKeyChecking=no "packer@$IP" ver
    case $? in
      (0) echo "${index}> Success"; ((success+=1));;
      (*) echo "${index} of ${maxConnectionAttempts}> SSH server not ready yet, waiting ${sleepSeconds} seconds..."; success=0 ;;
    esac
    if [ $success -eq 2 ]; then
      break
    fi
    sleep $sleepSeconds
    ((index+=1))
  done
  set -e

  ssh-keygen -R "${IP}"
  ssh-keyscan "${IP}" >>~/.ssh/known_hosts
}

if [ "${HYPERVISOR}" == "hyperv" ]; then
  azure_create "${NAME}" "${HYPERVISOR}"
elif [ "${HYPERVISOR}" == "azure" ]; then
  azure_create "${NAME}" "${HYPERVISOR}"
else
  PROJECTID=$(packet -k "${TOKEN}" \
    admin list-projects | jq -r ".[] | select(.name == \"${PROJECT}\") .id")

  "${COMMAND}" "${NAME}" "${PROJECTID}" "${HYPERVISOR}"
fi
