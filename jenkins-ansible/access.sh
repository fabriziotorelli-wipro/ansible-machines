#!/bin/bash
EXISTS="$(docker ps -a|grep jenkins-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker exec -it jenkins-ansible bash
else
  echo "Container jenkins-ansible not found ..."
fi
