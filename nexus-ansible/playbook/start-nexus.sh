#!/bin/bash
# RUN_AS_USER=root
function isNexusRunning {
  RUNNING="$(curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2)"
  if [[ "200" != "$RUNNING" ]]; then
    eval "$1="false""
  else
    eval "$1="true""
  fi
}
function checkNexusIsUp {
  COUNTER=0
  echo "Waiting for Nexus to be up and running ..."
  NEXUS_UP="$(curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2)"
  while [[ 200 != "$NEXUS_UP" && $COUNTER -lt 18 ]]
  do
    sleep 10
    echo "Waiting for Nexus to be up and running ..."
    NEXUS_UP="$(curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2)"
    let COUNTER=COUNTER+1
  done
}
RUNNING="false"
isNexusRunning RUNNING
if [[ "true" != "$RUNNING" ]]; then
  nexus start
  checkNexusIsUp
  echo "Nexus started ..."
else
  echo "Nexus already started!!"
fi
