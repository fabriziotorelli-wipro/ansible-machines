#!/bin/bash
EXISTS="$(docker ps -a|grep jenkins-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f jenkins-ansible
fi
# --cap-add SYS_ADMIN --security-opt seccomp:unconfined
#--privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup
docker run -d  -p 8080:8080 -p 50000:50000 --privileged -e "container=docker" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup -it --name jenkins-ansible buildit/jenkins-ansible
docker logs -f jenkins-ansible
