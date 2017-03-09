#!/bin/bash
EXISTS="$(docker images -a|grep 'buildit/centos7-ansible')"
if ! [[ -z "$EXISTS" ]]; then
  docker rmi -f buildit/centos7-ansible
fi
if ! [[ -z "$(docker images -a|grep -v 'IMAGE'|grep -i '<none>')" ]]; then
  docker images -a|grep -v 'IMAGE'|grep -i '<none>'|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
fi
#rm -f playbook.tgz
#tar -cvzf playbook.tgz playbook
docker build --compress --no-cache --rm --force-rm --tag buildit/centos7-ansible ./
