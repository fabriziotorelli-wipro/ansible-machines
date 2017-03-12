#!/bin/bash
EXISTS="$(docker ps -a|grep nexus-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker exec -it nexus-ansible bash
else
  echo "Container nexus-ansible not found ..."
fi
