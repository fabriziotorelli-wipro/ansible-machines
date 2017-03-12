FROM postgres:9.6

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
    ANSIBLE_HOSTNAME="" \
    HOSTNAME="" \
    RIGLETDOMAIN="" \
    PRIVATE_PUBLIC_KEY_TAR_URL="" \
    PRESTART_POSTGRES="true" \
    RESTART_POSTGRES_AFTER_ANSIBLE="false" \
    PATH=/usr/local/share/ansible/playbook:$PATH \
    POSTGRES_OS_USER="" \
    POSTGRES_OS_GROUP="" \
    POSTGRES_PASSWORD="mysecuritypassword" \
    POSTGRES_USER="postgres" \
    POSTGRES_DB="postgres" \
    PGDATA="/var/lib/postgresql/data" \
    POSTGRES_INITDB_ARGS=""




WORKDIR /usr/local/share/ansible

USER root

RUN apt-get update

RUN apt-get -y install --no-install-recommends sssd realmd adcli samba-common ntpdate ntp sudo apt-utils \
            libffi-dev libssl-dev libxml2-dev libxslt1-dev make asciidoc openssl tar groovy unzip monit curl \
            python python-pip python-dev build-essential cron vim zip python-psycopg2 python-pycurl git wget postgresql-client \
            locales ca-certificates openssh-server && pip install --upgrade pip &&  pip install ansible httplib2 docker-py && \
     apt-get -y upgrade && \
     mkdir -p /usr/local/share/ansible

COPY ./playbook /usr/local/share/ansible/playbook

RUN chmod 777 /usr/local/share/ansible/playbook/run_ansible_playbook.sh && \
    chmod 777 /usr/local/share/ansible/playbook/template/postgresql-entrypoint.sh && \
    chmod 777 /usr/local/share/ansible/playbook/template/start-postgresql.sh && \
    chmod 777 /usr/local/share/ansible/playbook/template/stop-postgresql.sh && \
    chmod 777 /usr/local/share/ansible/playbook/template/docker-entrypoint.sh && \
    mv /usr/local/share/ansible/playbook/template/postgresql-entrypoint.sh /usr/local/bin/postgresql-entrypoint.sh && \
    mv /usr/local/share/ansible/playbook/template/start-postgresql.sh /usr/local/bin/start-postgresql.sh && \
    mv /usr/local/share/ansible/playbook/template/stop-postgresql.sh /usr/local/bin/stop-postgresql.sh && \
    mv /usr/local/share/ansible/playbook/template/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh && \
    rm -f /docker-entrypoint.sh && \
    ln -s /usr/local/bin/docker-entrypoint.sh / && \
    mkdir -p /home/postgres/.ssh && \
    mkdir -p /postgres-entrypoint-initdb.d && \
    sudo chmod -Rf 777 /usr/local/bin/* && \
    chown -Rf postgres:postgres /postgres-entrypoint-initdb.d && \
    chown -Rf postgres:postgres /var/lib/postgresql && \
    chown -Rf postgres:postgres /home/postgres && \
    chmod 700 /var/lib/postgresql/data && \
    chown -Rf postgres:postgres /usr/local/share/ansible/playbook

RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*;

 RUN echo "Init postgres super-user ..." && cp /etc/sudoers /root/sudoers && \
     chmod 777 /root/sudoers && \
     echo "postgres  ALL=(ALL) NOPASSWD:ALL" >> /root/sudoers && \
     chmod 400 /root/sudoers && mv /root/sudoers /etc/sudoers && \
     usermod -aG ssh postgres

USER postgres

WORKDIR /usr/local/share/ansible/playbook

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/bin/bash", "-c", "run_ansible_playbook.sh"]

EXPOSE 5432

VOLUME ["/var/lib/postgresql/data", "/postgres-entrypoint-initdb.d"]
