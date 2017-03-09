FROM ansible/centos7-ansible:stable

MAINTAINER Fabrizio Torelli (fabrizio.torelli@wipro.com)

ENV MAIN_REPO_URL='git@bitbucket.org:digitalrigbitbucketteam/digitalrig-riglet.git' \
    MAIN_REPO_BRANCH=microservices-poc \
    MAIN_REPO_FOLDER=ec2 \
    ROLES_REPO_URL='git@bitbucket.org:digitalrigbitbucketteam/dr-scripts.git' \
    ROLES_REPO_BRANCH=microservices-poc \
    ROLES_REPO_FOLDER=roles \
    PLAYBOOKS=../jenkins,microservices \
    USER_NAME=fabriziotorelli \
    USER_EMAIL=fabrizio.torelli@wipro.com \
    USER_CREDENTIALS= \
    ANSIBLE_HOSTNAME=jenkins \
    HOSTNAME=jenkins \
    RIGLETDOMAIN=riglet \
    PATH=/opt/ansible/playbook:$PATH


WORKDIR /opt/ansible

USER root

RUN yum -y install epel-release deltarpm

RUN yum -y  install --skip-broken sssd realmd krb5-workstation oddjob oddjob-mkhomedir adcli samba-common ntpdate ntp sudo \
            libffi-dev libssl-dev libxml2-dev libxslt1-dev make asciidoc openssl openssl-devel tar parted groovy unzip \
            vim curl wget zip &&  pip install ansible httplib2 docker-py && pip install --upgrade pip

COPY ./playbook /opt/ansible/playbook

RUN chmod 777 /opt/ansible/playbook/run_ansible_playbook.sh

RUN mkdir -p /root/.ssh

COPY ./keys/* /root/.ssh/

WORKDIR /opt/ansible/playbook

CMD ["/bin/bash", "-c", "run_ansible_playbook.sh"]

#ENTRYPOINT ["/bin/bash"]
