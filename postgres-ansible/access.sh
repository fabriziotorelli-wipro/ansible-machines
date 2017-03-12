#!/bin/bash
EXISTS="$(docker ps -a|grep postgresql-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker exec -it postgresql-ansible bash
else
  echo "Container postgresql-ansible not found ..."
fi
