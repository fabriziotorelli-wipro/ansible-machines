#!/bin/bash
EXISTS="$(docker images -a|grep 'wipro/centos7-ansible')"
if ! [[ -z "$EXISTS" ]]; then
  docker rmi -f wipro/centos7-ansible
fi
docker images -a|grep -v 'IMAGE'|grep -i '<none>'|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
#rm -f playbook.tgz
#tar -cvzf playbook.tgz playbook
docker build --compress --no-cache --rm --force-rm --tag wipro/centos7-ansible ./
