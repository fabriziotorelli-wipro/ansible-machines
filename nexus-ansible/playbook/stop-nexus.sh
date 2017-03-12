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
RUNNING="false"
isNexusRunning RUNNING
if [[ "true" == "$RUNNING" ]]; then
  nexus stop
else
  echo "Nexus not running ..."
fi
