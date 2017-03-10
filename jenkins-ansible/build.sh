#!/bin/bash
rm -f keys.tar
cd keys
tar -cvf ../keys.tar *
cd ..
EXISTS="$(docker images -a|grep 'buildit/jenkins-ansible')"
if ! [[ -z "$EXISTS" ]]; then
  docker rmi -f builditftorelli/jenkins-ansible:2.32.3
  docker rmi -f buildit/jenkins-ansible:2.32.3
fi
if ! [[ -z "$(docker images -a|grep -v 'IMAGE'|grep -i '<none>')" ]]; then
  docker images -a|grep -v 'IMAGE'|grep -i '<none>'|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
fi
#rm -f playbook.tgz
#tar -cvzf playbook.tgz playbook
docker build --compress --no-cache --rm --force-rm --tag buildit/jenkins-ansible:2.32.3 ./
docker tag buildit/jenkins-ansible:2.32.3 builditftorelli/jenkins-ansible:2.32.3
