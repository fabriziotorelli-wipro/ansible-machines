#!/bin/bash
EXISTS="$(docker ps -a|grep postgres-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker exec -it postgres-ansible bash
else
  echo "Container postgres-ansible not found ..."
fi
