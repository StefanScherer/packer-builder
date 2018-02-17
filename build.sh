#!/bin/bash
NAME=$1
FILE=$2

if [ -z "${NAME}" ] || [ "${NAME}" == "--help" ] || [ -z "${FILE}" ]; then
  echo "Usage: $0 machine jobname"
  echo "$0 p1 windows_2016_docker"
  exit 1
fi

scp packer-build.sh root@$(./packet.sh ip $NAME):
ssh root@$(./packet.sh ip $NAME) tmux send-keys -t "gotty:0" "./packer-build.sh $FILE" Enter
