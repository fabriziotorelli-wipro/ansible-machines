#!/bin/bash
EXISTS="$(docker ps -a|grep nexus-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f nexus-ansible
fi
EXISTS="$(docker ps -a|grep nexus-ansible-volumes)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f nexus-ansible-volumes
fi
# --cap-add SYS_ADMIN --security-opt seccomp:unconfined
#--privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup
#docker run -d  -p 8080:8080 -p 50000:50000 --privileged -e "PLUGINS_TEXT_FILE_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/nexus-ansible/plugins.txt" -e "PRIVATE_PUBLIC_KEY_TAR_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/nexus-ansible/keys.tar" -e "container=docker" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup -it --name nexus-ansible buildit/nexus-ansible:oss
MAIN_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/digitalrig-riglet.git"
MAIN_REPO_BRANCH="microservices-poc-rancher"
MAIN_REPO_FOLDER="ec2"
ROLES_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/dr-scripts.git"
ROLES_REPO_BRANCH="microservices-poc-rancher"
ROLES_REPO_FOLDER="roles"
PLAYBOOKS="../nexus"
USER_NAME="fabriziotorelli"
USER_EMAIL="fabrizio.torelli@wipro.com"
USER_CREDENTIALS=""
ANSIBLE_HOSTNAME="nexus"
HOSTNAME="nexus"
RIGLETDOMAIN="riglet"
PRESTART_NEXUS="false"
POSTSTART_NEXUS="false"
RESTART_NEXUS_AFTER_ANSIBLE="true"
PRIVATE_PUBLIC_KEY_TAR_URL="https://github.com/hellgate75/online-keys/raw/master/20170311/nexus/keys.tar"
docker run -d --privileged -e "MAIN_REPO_URL=$MAIN_REPO_URL" -e "PLAYBOOKS=$PLAYBOOKS" \
          -e "MAIN_REPO_BRANCH=$MAIN_REPO_BRANCH" -e "MAIN_REPO_FOLDER=$MAIN_REPO_FOLDER" -e "ROLES_REPO_URL=$ROLES_REPO_URL" \
          -e "ROLES_REPO_BRANCH=$ROLES_REPO_BRANCH" -e "ROLES_REPO_FOLDER=$ROLES_REPO_FOLDER" -e "USER_NAME=$USER_NAME" \
          -e "USER_EMAIL=$USER_EMAIL" -e "USER_CREDENTIALS=$USER_CREDENTIALS" -e "ANSIBLE_HOSTNAME=$ANSIBLE_HOSTNAME" \
          -e "RIGLETDOMAIN=$RIGLETDOMAIN" -e "HOSTNAME=$HOSTNAME" -e "PRIVATE_PUBLIC_KEY_TAR_URL=$PRIVATE_PUBLIC_KEY_TAR_URL" \
          -e "PRESTART_NEXUS=$PRESTART_NEXUS" -e "POSTSTART_NEXUS=$POSTSTART_NEXUS" \
          -e "RESTART_NEXUS_AFTER_ANSIBLE=$RESTART_NEXUS_AFTER_ANSIBLE" -e "container=docker" \
          --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup \
          -it --name nexus-ansible-volumes builditftorelli/nexus-ansible:oss echo "I am just a volume source!!"
docker run -d  -p 9003:8081 -e "MAIN_REPO_URL=$MAIN_REPO_URL" -e "PLAYBOOKS=$PLAYBOOKS" \
          -e "MAIN_REPO_BRANCH=$MAIN_REPO_BRANCH" -e "MAIN_REPO_FOLDER=$MAIN_REPO_FOLDER" -e "ROLES_REPO_URL=$ROLES_REPO_URL" \
          -e "ROLES_REPO_BRANCH=$ROLES_REPO_BRANCH" -e "ROLES_REPO_FOLDER=$ROLES_REPO_FOLDER" -e "USER_NAME=$USER_NAME" \
          -e "USER_EMAIL=$USER_EMAIL" -e "USER_CREDENTIALS=$USER_CREDENTIALS" -e "ANSIBLE_HOSTNAME=$ANSIBLE_HOSTNAME" \
          -e "RIGLETDOMAIN=$RIGLETDOMAIN" -e "HOSTNAME=$HOSTNAME" -e "PRIVATE_PUBLIC_KEY_TAR_URL=$PRIVATE_PUBLIC_KEY_TAR_URL" \
          -e "PRESTART_NEXUS=$PRESTART_NEXUS" -e "POSTSTART_NEXUS=$POSTSTART_NEXUS" \
          -e "RESTART_NEXUS_AFTER_ANSIBLE=$RESTART_NEXUS_AFTER_ANSIBLE" -e "container=docker" \
          -it --name nexus-ansible --volumes-from nexus-ansible-volumes builditftorelli/nexus-ansible:oss
docker logs -f nexus-ansible
