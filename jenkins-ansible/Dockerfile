FROM jenkins:2.32.3

MAINTAINER Fabrizio Torelli (fabrizio.torelli@wipro.com)

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
    PLUGINS_TEXT_FILE_URL="" \
    PRESTART_JENKINS="true" \
    PRESTART_JENKINS_IF_UP_POST_ANSIBLE="false" \
    RESTART_JENKINS_AFTER_ANSIBLE="false" \
    PATH=/usr/local/share/ansible/playbook:$PATH \
    JAVA_OPTS="-Xmx4096m -Djenkins.install.runSetupWizard=false" \
    JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war" \
    JENKINS_VERSION='2.32.3'


WORKDIR /usr/local/share/ansible

USER root

RUN apt-get update

RUN apt-get -y install --no-install-recommends sssd realmd adcli samba-common ntpdate ntp sudo \
            libffi-dev libssl-dev libxml2-dev libxslt1-dev make asciidoc openssl tar groovy unzip \
            python python-pip python-dev build-essential cron vim zip && pip install --upgrade pip \
             &&  pip install ansible httplib2 docker-py
RUN apt-get -y upgrade

RUN mkdir -p /usr/local/share/ansible

COPY ./playbook /usr/local/share/ansible/playbook

RUN chmod 777 /usr/local/share/ansible/playbook/run_ansible_playbook.sh

RUN mkdir -p /root/.ssh

RUN mkdir -p /var/jenkins_home/.ssh

RUN chown -Rf jenkins:jenkins /var/jenkins_home
RUN chown -Rf jenkins:jenkins /usr/local/share/ansible/playbook

RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*;

 RUN echo "Init jenkins super-user ..." && cp /etc/sudoers /root/sudoers && \
     chmod 777 /root/sudoers && \
     echo "jenkins  ALL=(ALL) NOPASSWD:ALL" >> /root/sudoers && \
     chmod 400 /root/sudoers && mv /root/sudoers /etc/sudoers

RUN mkdir /var/log/jenkins
RUN mkdir /var/cache/jenkins
RUN chown -R  jenkins:jenkins /var/log/jenkins
RUN chown -R  jenkins:jenkins /var/cache/jenkins
RUN chown -R  jenkins:jenkins /usr/share/jenkins
RUN usermod -aG ssh jenkins
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

USER jenkins

# "For 2.x-derived images, you may also want to" - we're 2.0 dervied, so we want this
RUN echo "$JENKINS_VERSION" > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo "$JENKINS_VERSION" > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

WORKDIR /usr/local/share/ansible/playbook

CMD ["/bin/bash", "-c", "run_ansible_playbook.sh"]
EXPOSE 8080 50000
