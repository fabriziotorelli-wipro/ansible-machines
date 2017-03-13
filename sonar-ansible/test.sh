#!/bin/bash
EXISTS="$(docker ps -a|grep sonarqube-ansible)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f sonarqube-ansible
fi
EXISTS="$(docker ps -a|grep sonarqube-ansible-volumes)"
if ! [[ -z "$EXISTS" ]]; then
  docker rm -f sonarqube-ansible-volumes
fi
# --cap-add SYS_ADMIN --security-opt seccomp:unconfined
#--privileged -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup
#docker run -d  -p 8080:8080 -p 50000:50000 --privileged -e "PLUGINS_TEXT_FILE_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/sonarqube-ansible/plugins.txt" -e "PRIVATE_PUBLIC_KEY_TAR_URL=https://github.com/fabriziotorelli-wipro/ansible-machines/raw/master/sonarqube-ansible/keys.tar" -e "container=docker" --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup -it --name sonarqube-ansible buildit/sonarqube-ansible:oss
MAIN_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/digitalrig-riglet.git"
MAIN_REPO_BRANCH="microservices-poc-rancher"
MAIN_REPO_FOLDER="ec2"
ROLES_REPO_URL="git@bitbucket.org:digitalrigbitbucketteam/dr-scripts.git"
ROLES_REPO_BRANCH="microservices-poc-rancher"
ROLES_REPO_FOLDER="roles"
PLAYBOOKS="../sonar"
USER_NAME="fabriziotorelli"
USER_EMAIL="fabrizio.torelli@wipro.com"
USER_CREDENTIALS=""
ANSIBLE_HOSTNAME="sonar"
HOSTNAME="sonar"
RIGLETDOMAIN="riglet"
PRESTART_SONARQUBE="false"
POSTSTART_SONARQUBE="false"
SONARQUBE_JDBC_USERNAME="sonarqube"
SONARQUBE_JDBC_PASSWORD="4n4lys1s"
SONARQUBE_JDBC_URL="jdbc:postgresql://sonar-db.riglet:5432/sonarqube"
SONARQUBE_WEB_JVM_OPTS=""
RESTART_SONARQUBE_AFTER_ANSIBLE="false"
PRIVATE_PUBLIC_KEY_TAR_URL="https://github.com/hellgate75/online-keys/raw/master/20170311/sonarqube/keys.tar"
docker run -d --privileged -e "MAIN_REPO_URL=$MAIN_REPO_URL" -e "PLAYBOOKS=$PLAYBOOKS" \
          -e "MAIN_REPO_BRANCH=$MAIN_REPO_BRANCH" -e "MAIN_REPO_FOLDER=$MAIN_REPO_FOLDER" -e "ROLES_REPO_URL=$ROLES_REPO_URL" \
          -e "ROLES_REPO_BRANCH=$ROLES_REPO_BRANCH" -e "ROLES_REPO_FOLDER=$ROLES_REPO_FOLDER" -e "USER_NAME=$USER_NAME" \
          -e "USER_EMAIL=$USER_EMAIL" -e "USER_CREDENTIALS=$USER_CREDENTIALS" -e "ANSIBLE_HOSTNAME=$ANSIBLE_HOSTNAME" \
          -e "RIGLETDOMAIN=$RIGLETDOMAIN" -e "HOSTNAME=$HOSTNAME" -e "PRIVATE_PUBLIC_KEY_TAR_URL=$PRIVATE_PUBLIC_KEY_TAR_URL" \
          -e "PRESTART_SONARQUBE=$PRESTART_SONARQUBE" -e "POSTSTART_SONARQUBE=$POSTSTART_SONARQUBE" \
          -e "SONARQUBE_JDBC_USERNAME=$SONARQUBE_JDBC_USERNAME" -e "SONARQUBE_JDBC_PASSWORD=$SONARQUBE_JDBC_PASSWORD" \
          -e "SONARQUBE_JDBC_URL=$SONARQUBE_JDBC_URL" -e "SONARQUBE_WEB_JVM_OPTS=$SONARQUBE_WEB_JVM_OPTS" \
          -e "RESTART_SONARQUBE_AFTER_ANSIBLE=$RESTART_SONARQUBE_AFTER_ANSIBLE" -e "container=docker" \
          --cap-add SYS_ADMIN --security-opt seccomp:unconfined -v /sys/fs/cgroup:/sys/fs/cgroup \
          -it --name sonarqube-ansible-volumes builditftorelli/sonarqube-ansible:6.2 echo "I am just a volume source!!"
docker stop sonarqube-ansible-volumes
docker run -d  -p 9000:9000 -p 9092:9092 -e "MAIN_REPO_URL=$MAIN_REPO_URL" -e "PLAYBOOKS=$PLAYBOOKS" \
          -e "MAIN_REPO_BRANCH=$MAIN_REPO_BRANCH" -e "MAIN_REPO_FOLDER=$MAIN_REPO_FOLDER" -e "ROLES_REPO_URL=$ROLES_REPO_URL" \
          -e "ROLES_REPO_BRANCH=$ROLES_REPO_BRANCH" -e "ROLES_REPO_FOLDER=$ROLES_REPO_FOLDER" -e "USER_NAME=$USER_NAME" \
          -e "USER_EMAIL=$USER_EMAIL" -e "USER_CREDENTIALS=$USER_CREDENTIALS" -e "ANSIBLE_HOSTNAME=$ANSIBLE_HOSTNAME" \
          -e "RIGLETDOMAIN=$RIGLETDOMAIN" -e "HOSTNAME=$HOSTNAME" -e "PRIVATE_PUBLIC_KEY_TAR_URL=$PRIVATE_PUBLIC_KEY_TAR_URL" \
          -e "PRESTART_SONARQUBE=$PRESTART_SONARQUBE" -e "POSTSTART_SONARQUBE=$POSTSTART_SONARQUBE" \
          -e "SONARQUBE_JDBC_USERNAME=$SONARQUBE_JDBC_USERNAME" -e "SONARQUBE_JDBC_PASSWORD=$SONARQUBE_JDBC_PASSWORD" \
          -e "SONARQUBE_JDBC_URL=$SONARQUBE_JDBC_URL" -e "SONARQUBE_WEB_JVM_OPTS=$SONARQUBE_WEB_JVM_OPTS" \
          -e "RESTART_SONARQUBE_AFTER_ANSIBLE=$RESTART_SONARQUBE_AFTER_ANSIBLE" -e "container=docker" \
          -it --name sonarqube-ansible --volumes-from sonarqube-ansible-volumes builditftorelli/sonarqube-ansible:6.2
docker logs -f sonarqube-ansible
