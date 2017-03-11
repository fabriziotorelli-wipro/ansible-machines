#!/bin/bash
EXISTS="$(docker ps -a|grep jenkins-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f jenkins-ansible
fi
# --cap-add SYS_ADMIN --security-opt seccomp:unconfined
#--privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup
#docker run -d  -p 8080:8080 -p 50000:50000 --privileged -e "PLUGINS_TEXT_FILE_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/jenkins-ansible/plugins.txt" -e "PRIVATE_PUBLIC_KEY_TAR_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/jenkins-ansible/keys.tar" -e "container=docker" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup -it --name jenkins-ansible buildit/jenkins-ansible:2.32.3
MAIN_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/digitalrig-riglet.git"
MAIN_REPO_BRANCH="microservices-poc-rancher"
MAIN_REPO_FOLDER="ec2"
ROLES_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/dr-scripts.git"
ROLES_REPO_BRANCH="microservices-poc-rancher"
ROLES_REPO_FOLDER="roles"
PLAYBOOKS="../jenkins,microservices,microservices-recreate"
USER_NAME="fabriziotorelli"
USER_EMAIL="fabrizio.torelli@wipro.com"
USER_CREDENTIALS=""
ANSIBLE_HOSTNAME="jenkins"
HOSTNAME="jenkins"
RIGLETDOMAIN="riglet"
PRIVATE_PUBLIC_KEY_TAR_URL="https://github.com/hellgate75/online-keys/raw/master/20170311/jenkins/keys.tar"
PLUGINS_TEXT_FILE_URL=""
docker run -d  -p 8080:8080 -p 50000:50000 --privileged -e "MAIN_REPO_URL=$MAIN_REPO_URL" -e "PLAYBOOKS=$PLAYBOOKS" \
          -e "MAIN_REPO_BRANCH=$MAIN_REPO_BRANCH" -e "MAIN_REPO_FOLDER=$MAIN_REPO_FOLDER" -e "ROLES_REPO_URL=$ROLES_REPO_URL" \
          -e "ROLES_REPO_BRANCH=$ROLES_REPO_BRANCH" -e "ROLES_REPO_FOLDER=$ROLES_REPO_FOLDER" -e "USER_NAME=$USER_NAME" \
          -e "USER_EMAIL=$USER_EMAIL" -e "USER_CREDENTIALS=$USER_CREDENTIALS" -e "ANSIBLE_HOSTNAME=$ANSIBLE_HOSTNAME" \
          -e "RIGLETDOMAIN=$RIGLETDOMAIN" -e "HOSTNAME=$HOSTNAME" -e "PRIVATE_PUBLIC_KEY_TAR_URL=$PRIVATE_PUBLIC_KEY_TAR_URL" \
          -e "PLUGINS_TEXT_FILE_URL=$PLUGINS_TEXT_FILE_URL" -e "container=docker" \
          --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup \
          -it --name jenkins-ansible buildit/jenkins-ansible:2.32.3
docker logs -f jenkins-ansible
