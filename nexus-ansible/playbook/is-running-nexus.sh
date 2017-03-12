#!/bin/bash
function isNexusRunning {
  RUNNING="$(curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2)"
  if [[ "200" != "$RUNNING" ]]; then
    echo "false"
  else
    echo "true"
  fi
}
isNexusRunning
