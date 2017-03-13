#!/bin/bash
EXISTS="$(docker ps -a|grep postgresql-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f postgresql-ansible
fi
EXISTS="$(docker ps -a|grep postgresql-ansible-volumes)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f postgresql-ansible-volumes
fi
docker volume prune -f
MAIN_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/digitalrig-riglet.git"
MAIN_REPO_BRANCH="microservices-poc-rancher"
MAIN_REPO_FOLDER="ec2"
ROLES_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/dr-scripts.git"
ROLES_REPO_BRANCH="microservices-poc-rancher"
ROLES_REPO_FOLDER="roles"
PLAYBOOKS="../sonar"
USER_NAME="fabriziotorelli"
USER_EMAIL="fabrizio.torelli@wipro.com"
ANSIBLE_HOSTNAME="postgres"
HOSTNAME="sonar-db"
RIGLETDOMAIN="riglet"
PRESTART_POSTGRES="true"
POSTGRES_PASSWORD="4n4lys1s"
POSTGRES_USER="sonarqube"
POSTGRES_DB="sonarqube"
POSTGRES_OS_USER=""
POSTGRES_OS_GROUP=""
PRIVATE_PUBLIC_KEY_TAR_URL="https://github.com/hellgate75/online-keys/raw/master/20170311/postgres/keys.tar"
docker run -d  --privileged -e "MAIN_REPO_URL=$MAIN_REPO_URL" -e "PLAYBOOKS=$PLAYBOOKS" -e "POSTGRES_USER=$POSTGRES_USER" \
          -e "MAIN_REPO_BRANCH=$MAIN_REPO_BRANCH" -e "MAIN_REPO_FOLDER=$MAIN_REPO_FOLDER" -e "ROLES_REPO_URL=$ROLES_REPO_URL" \
          -e "ROLES_REPO_BRANCH=$ROLES_REPO_BRANCH" -e "ROLES_REPO_FOLDER=$ROLES_REPO_FOLDER" -e "USER_NAME=$USER_NAME" \
          -e "USER_EMAIL=$USER_EMAIL" -e "USER_CREDENTIALS=$USER_CREDENTIALS" -e "ANSIBLE_HOSTNAME=$ANSIBLE_HOSTNAME" \
          -e "RIGLETDOMAIN=$RIGLETDOMAIN" -e "HOSTNAME=$HOSTNAME" -e "PRIVATE_PUBLIC_KEY_TAR_URL=$PRIVATE_PUBLIC_KEY_TAR_URL" \
          -e "POSTSTART_POSTGRES=$POSTSTART_POSTGRES" -e "PRESTART_POSTGRES=$PRESTART_POSTGRES" -e "container=docker" \
          -e "POSTGRES_DB=$POSTGRES_DB" -e "POSTGRES_OS_USER=$POSTGRES_OS_USER" -e "POSTGRES_OS_GROUP=$POSTGRES_OS_GROUP" \
          -e "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup \
          -it --name postgresql-ansible-volumes builditftorelli/postgresql-ansible:9.6.2 echo "I am just a volume source!!"
if [[ -e /vagrant/volumes/postgresql ]]; then
  rm -Rf /vagrant/volumes/postgresql
fi
mkdir -p /vagrant/volumes/postgresql
docker run -d  -p 5432:5432 --privileged -e "MAIN_REPO_URL=$MAIN_REPO_URL" -e "PLAYBOOKS=$PLAYBOOKS" -e "POSTGRES_USER=$POSTGRES_USER" \
          -e "MAIN_REPO_BRANCH=$MAIN_REPO_BRANCH" -e "MAIN_REPO_FOLDER=$MAIN_REPO_FOLDER" -e "ROLES_REPO_URL=$ROLES_REPO_URL" \
          -e "ROLES_REPO_BRANCH=$ROLES_REPO_BRANCH" -e "ROLES_REPO_FOLDER=$ROLES_REPO_FOLDER" -e "USER_NAME=$USER_NAME" \
          -e "USER_EMAIL=$USER_EMAIL" -e "USER_CREDENTIALS=$USER_CREDENTIALS" -e "ANSIBLE_HOSTNAME=$ANSIBLE_HOSTNAME" \
          -e "RIGLETDOMAIN=$RIGLETDOMAIN" -e "HOSTNAME=$HOSTNAME" -e "PRIVATE_PUBLIC_KEY_TAR_URL=$PRIVATE_PUBLIC_KEY_TAR_URL" \
          -e "POSTSTART_POSTGRES=$POSTSTART_POSTGRES" -e "PRESTART_POSTGRES=$PRESTART_POSTGRES" -e "container=docker" \
          -e "POSTGRES_DB=$POSTGRES_DB" -e "POSTGRES_OS_USER=$POSTGRES_OS_USER" -e "POSTGRES_OS_GROUP=$POSTGRES_OS_GROUP" \
          -e "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" --cap-add SYS_ADMIN --security-opt seccomp:unconfined \
          -v /sys/fs/cgroup:/sys/fs/cgroup -it --volumes-from postgresql-ansible-volumes \
          --name postgresql-ansible --user postgres:postgres builditftorelli/postgresql-ansible:9.6.2
docker logs -f postgresql-ansible
