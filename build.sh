#!/bin/bash
NAME=$1
FILE=$2
HYPERVISOR=$3
GITHUB_URL=${GITHUB_URL:-https://github.com/StefanScherer/packer-windows}

if [ -z "${NAME}" ] || [ "${NAME}" == "--help" ] || [ -z "${FILE}" ]; then
  echo "Usage: $0 machine jobname"
  echo "$0 p1 windows_2016_docker"
  exit 1
fi

function packet_build {
  ip=$(./machine.sh ip "$NAME")
  scp packer-build.sh "root@$ip":

  echo "Monitor the packer build with VNC and SSH"
  echo "See the VNC port number and password in packer output."
  echo ""
  echo "ssh -L 127.0.0.1:5900:127.0.0.1:59xx root@$ip tail -f work/packer-build.log"

  if [ -z "${!FILE}" ]; then
    echo Running build.
  else
    echo Running build with local ISO.
    ISO_URL="${!FILE}"
  fi

  # shellcheck disable=SC2029
  ssh -n -f "root@$(./machine.sh ip "$NAME")" "sh -c 'nohup ./packer-build.sh $FILE $HYPERVISOR $GITHUB_URL $ISO_URL > /dev/null 2>&1 &'"

  sleep 20

  if [ -z "$PACKET_APIKEY" ]; then
    echo "Skip upload"
  else
    today=$(date +%Y-%m-%d)
    cat <<CMD >packer-upload-and-destroy.sh
    export PACKET_APIKEY=$PACKET_APIKEY
    export AZURE_STORAGE_ACCOUNT=$AZURE_STORAGE_ACCOUNT
    export AZURE_STORAGE_ACCESS_KEY=$AZURE_STORAGE_ACCESS_KEY
    azure telemetry --enable
    if [ -e ${FILE}_vmware.box ]; then
      azure storage blob upload ${FILE}_vmware.box ${AZURE_STORAGE_CONTAINER} ${FILE}/$today/${FILE}_vmware.box
    fi
    if [ -e ${FILE}_virtualbox.box ]; then
      azure storage blob upload ${FILE}_virtualbox.box ${AZURE_STORAGE_CONTAINER} ${FILE}/$today/${FILE}_virtualbox.box
    fi
    echo "Deleting server."
    sleep 1
    killall -9 tail
    machine.sh delete \$(hostname)
CMD
    chmod +x packer-upload-and-destroy.sh
    scp packer-upload-and-destroy.sh "root@$ip:"
    scp "$(which packet)" "root@$ip:/usr/bin/packet"
    scp ./machine.sh "root@$ip:/usr/bin/machine.sh"
    rm packer-upload-and-destroy.sh
  fi

  set +e
  ssh "root@$(./machine.sh ip "$NAME")" tail -f work/packer-build.log | tee packer-build.log
  set -e

  hypervisor1=${HYPERVISOR%+*}
  hypervisor2=${HYPERVISOR#*+}

  echo Checking build artifacts.
  grep "$hypervisor1-iso: '$hypervisor1' provider box:" packer-build.log
  if [ "$hypervisor1" != "$hypervisor2" ]; then
    grep "$hypervisor2-iso: '$hypervisor2' provider box:" packer-build.log
  fi
}

function azure_build {
  cd hyperv
  IP=$(terraform output ip)
  echo "IP address of Azure VM $NAME: $IP"

  echo "Run packer build through SSH"
  scp packer-build.ps1 "packer@$IP:"
  scp -r . "packer@$IP:hyperv"
  # shellcheck disable=SC2029
  ssh -n -f "packer@$IP" "\"C:\\Program Files\\Git\\usr\\bin\\nohup.exe\" powershell -File packer-build.ps1 $FILE $HYPERVISOR $GITHUB_URL $ISO_URL"

  sleep 5

  set +e
  ssh "packer@$IP" 'C:\Program Files\Git\usr\bin\tail.exe' -f work/packer-build.log | tee packer-build.log
  set -e

  echo Checking build artifacts.
  grep "$hypervisor1-iso: '$hypervisor1' provider box:" packer-build.log
}

if [ "${HYPERVISOR}" == "hyperv" ]; then
  azure_build
else
  packet_build
fi
