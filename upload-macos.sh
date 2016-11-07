#!/bin/bash
NAME=$1
FILE=macos1012

if [ -z "${NAME}" ] || [ "${NAME}" == "--help" ] || [ -z "${FILE}" ]; then
  echo "Usage: $0 machine"
  echo "$0 p1"
  exit 1
fi

today=$(date +%Y-%m-%d)
cat <<CMD | ssh root@$(./packet.sh ip $NAME)
$(pass azure-vagrantboxes)
azure telemetry --disable
azure storage blob upload macos/box/vmware/${FILE}-nocm-0.1.0.box box ${FILE}/$today/${FILE}_vmware.box
CMD
