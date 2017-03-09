#!/bin/bash
 EXISTS="$(docker ps -a|grep centos7ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f centos7ansible
fi
# --cap-add SYS_ADMIN --security-opt seccomp:unconfined
#--privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup
docker run -d  --privileged -e "container=docker" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup -it --name centos7ansible wipro/centos7-ansible
docker logs -f centos7ansible
