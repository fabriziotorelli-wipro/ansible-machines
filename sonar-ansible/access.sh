#!/bin/bash
EXISTS="$(docker ps -a|grep sonarqube-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker exec -it sonarqube-ansible bash
else
  echo "Container sonarqube-ansible not found ..."
fi
