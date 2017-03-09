FROM jenkins

MAINTAINER Fabrizio Torelli (fabrizio.torelli@wipro.com)

ENV MAIN_REPO_URL='git@bitbucket.org:digitalrigbitbucketteam/digitalrig-riglet.git' \
    MAIN_REPO_BRANCH=microservices-poc \
    MAIN_REPO_FOLDER=ec2 \
    ROLES_REPO_URL='git@bitbucket.org:digitalrigbitbucketteam/dr-scripts.git' \
    ROLES_REPO_BRANCH=microservices-poc-rancher \
    ROLES_REPO_FOLDER=roles \
    PLAYBOOKS=../jenkins,microservices \
    USER_NAME=fabriziotorelli \
    USER_EMAIL=fabrizio.torelli@wipro.com \
    USER_CREDENTIALS= \
    ANSIBLE_HOSTNAME=jenkins \
    HOSTNAME=jenkins \
    RIGLETDOMAIN=riglet \
    PATH=/usr/local/share/ansible/playbook:$PATH


WORKDIR /usr/local/share/ansible

USER root

RUN apt-get update

RUN apt-get -y install --no-install-recommends sssd realmd adcli samba-common ntpdate ntp sudo \
            libffi-dev libssl-dev libxml2-dev libxslt1-dev make asciidoc openssl tar groovy unzip \
            python python-pip python-dev build-essential  vim zip && pip install --upgrade pip \
             &&  pip install ansible httplib2 docker-py
RUN apt-get -y upgrade

RUN mkdir -p /usr/local/share/ansible

COPY ./playbook /usr/local/share/ansible/playbook

RUN chmod 777 /usr/local/share/ansible/playbook/run_ansible_playbook.sh

RUN mkdir -p /root/.ssh

RUN mkdir -p /home/jenkins/.ssh

COPY ./keys/* /root/.ssh/
COPY ./keys/* /home/jenkins/.ssh/
RUN chmod 600 -f /home/jenkins/.ssh/id_rsa*
RUN chmod 600 -f /root/.ssh/id_rsa*
RUN mkdir -p /home/jenkins/.ssh

RUN chown -Rf jenkins:jenkins /home/jenkins

RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*;

 RUN echo "Init jenkins super-user ..." && cp /etc/sudoers /root/sudoers && \
     chmod 777 /root/sudoers && \
     echo "jenkins  ALL=(ALL) NOPASSWD:ALL" >> /root/sudoers && \
     chmod 400 /root/sudoers && mv /root/sudoers /etc/sudoers


USER root

WORKDIR /usr/local/share/ansible/playbook

CMD ["/bin/bash", "-c", "run_ansible_playbook.sh"]

#ENTRYPOINT ["/bin/bash"]
