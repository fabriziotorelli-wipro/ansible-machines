FROM jenkins

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

RUN apt-get update

RUN apt-get -y install --no-install-recommends sssd realmd adcli samba-common ntpdate ntp sudo \
            libffi-dev libssl-dev libxml2-dev libxslt1-dev make asciidoc openssl tar groovy unzip \
            python python-pip python-dev build-essential  vim zip && pip install --upgrade pip \
             &&  pip install ansible httplib2 docker-py
RUN apt-get -y upgrade

COPY ./playbook /opt/ansible/playbook

RUN chmod 777 /opt/ansible/playbook/run_ansible_playbook.sh

RUN mkdir -p /root/.ssh

RUN mkdir -p /home/jenkins/.ssh

COPY ./keys/* /root/.ssh/
COPY ./keys/* /home/jenkins/.ssh/

# RUN cp /etc/sudoers /root/sudoers && chmod 777 /root/sudoers
# RUN echo "jenkins  ALL=(ALL) NOPASSWD:ALL" > /root/sudoers && chmod 400 sudoers && mv /root/sudoers /etc/sudoers

USER jenkins

WORKDIR /opt/ansible/playbook

CMD ["/bin/bash", "-c", "run_ansible_playbook.sh"]

#ENTRYPOINT ["/bin/bash"]
