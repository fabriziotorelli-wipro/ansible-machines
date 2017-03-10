#!/bin/bash
EXISTS="$(docker ps -a|grep jenkins-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f jenkins-ansible
fi
# --cap-add SYS_ADMIN --security-opt seccomp:unconfined
#--privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup
#docker run -d  -p 8080:8080 -p 50000:50000 --privileged -e "PLUGINS_TEXT_FILE_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/jenkins-ansible/plugins.txt" -e "PRIVATE_PUBLIC_KEY_TAR_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/jenkins-ansible/keys.tar" -e "container=docker" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup -it --name jenkins-ansible buildit/jenkins-ansible:2.32.3
docker run -d  -p 8080:8080 -p 50000:50000 --privileged -e "PLAYBOOKS=../jenkins,microservices,microservices-recreate" -e "PRIVATE_PUBLIC_KEY_TAR_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/jenkins-ansible/keys.tar" -e "container=docker" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup -it --name jenkins-ansible buildit/jenkins-ansible:2.32.3
docker logs -f jenkins-ansible
