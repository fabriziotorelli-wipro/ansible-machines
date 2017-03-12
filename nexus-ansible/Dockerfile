FROM sonatype/nexus:oss

MAINTAINER Fabrizio Torelli (fabrizio.torelli@wipro.com)

LABEL vendor=BuildIt \
  com.sonatype.license="Apache License, Version 2.0" \
  com.sonatype.name="Nexus Repository Manager Pro base image" \
  com.sonatype.type="Nexus Repository Ansible Repository Image"

ENV MAIN_REPO_URL="" \
    MAIN_REPO_BRANCH="" \
    MAIN_REPO_FOLDER="" \
    ROLES_REPO_URL="" \
    ROLES_REPO_BRANCH="" \
    ROLES_REPO_FOLDER="" \
    PLAYBOOKS="" \
    USER_NAME="" \
    USER_EMAIL="" \
    USER_CREDENTIALS="" \
    ANSIBLE_HOSTNAME="" \
    HOSTNAME="" \
    RIGLETDOMAIN="" \
    PRIVATE_PUBLIC_KEY_TAR_URL="" \
    PRESTART_NEXUS="true" \
    POSTSTART_NEXUS="false" \
    PRESTART_NEXUS_IF_UP_POST_ANSIBLE="false" \
    RESTART_NEXUS_AFTER_ANSIBLE="false" \
    PATH=/usr/local/share/ansible/playbook:/opt/sonatype/nexus/bin:$PATH \
    NEXUS_HOME="/opt/sonatype/nexus" \
    SONATYPE_WORK="/sonatype-work" \
    JAVA_HOME="/opt/java" \
    JAVA_VERSION_MAJOR="8" \
    JAVA_VERSION_MINOR="102" \
    JAVA_VERSION_BUILD="14" \
    CONTEXT_PATH="/nexus" \
    MAX_HEAP="768m" \
    MIN_HEAP="256m" \
    JAVA_OPTS="-server -Djava.net.preferIPv4Stack=true"  \
    LAUNCHER_CONF="./conf/jetty.xml ./conf/jetty-requestlog.xml"

WORKDIR /usr/local/share/ansible

USER root

RUN yum -y install epel-release deltarpm

RUN yum -y  install --skip-broken git python python-pip python-devel libffi-dev libssl-dev libxml2-dev libxslt1-dev \
            libjpeg8-dev zlib1g-dev gcc rpm-build make asciidoc python-setuptools openssl openssl-devel \
            tar groovy unzip vim curl wget zip sudo git openssh openssh-server openssh-clients openssl-libs && \
            pip install --upgrade pip && pip install ansible httplib2 docker-py

RUN mkdir -p /usr/local/share/ansible

COPY ./playbook /usr/local/share/ansible/playbook

RUN chmod 777 /usr/local/share/ansible/playbook/run_ansible_playbook.sh

RUN mkdir -p /root/.ssh

RUN mkdir -p /sonatype-work/.ssh

RUN chown -Rf nexus:nexus /sonatype-work
RUN chown -Rf nexus:nexus /usr/local/share/ansible/playbook
RUN chown -Rf nexus:nexus /opt/sonatype

RUN echo "Init nexus super-user ..." && cp /etc/sudoers /root/sudoers && \
     chmod 777 /root/sudoers && \
     echo "nexus  ALL=(ALL) NOPASSWD:ALL" >> /root/sudoers && \
     chmod 400 /root/sudoers && mv /root/sudoers /etc/sudoers

RUN groupadd ssh

RUN usermod -aG ssh nexus

RUN cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig

USER nexus

WORKDIR /usr/local/share/ansible/playbook

CMD ["/bin/bash", "-c", "run_ansible_playbook.sh"]

EXPOSE 8081

VOLUME ${SONATYPE_WORK}
