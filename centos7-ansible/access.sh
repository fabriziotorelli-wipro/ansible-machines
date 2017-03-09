#!/bin/bash
EXISTS="$(docker ps -a|grep centos7ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker exec -it centos7ansible bash
else
  echo "Container centos7ansible not found ..."
fi
