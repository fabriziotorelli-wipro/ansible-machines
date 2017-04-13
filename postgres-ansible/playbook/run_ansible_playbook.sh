#!/bin/bash
PLAYBOOK_FOLDER="/usr/local/share/ansible/playbook"

function configuringHosts {
  echo "Configuring ansible host to : $ANSIBLE_HOSTNAME"
  echo "Configuring machine host to : $HOSTNAME"
  echo "Configuring machine riglet domain to : $RIGLETDOMAIN"
  sudo cat /etc/hosts > /home/postgres/hosts
  sudo chown postgres:postgres /var/jenkins_home/hosts
  echo "127.0.0.1  localhost localhost.localdomain localhost.$RIGLETDOMAIN" >> /home/postgres/hosts
  echo "127.0.0.1  $HOSTNAME   $HOSTNAME.$RIGLETDOMAIN" >> /home/postgres/hosts
  sudo chmod 777 /etc/hosts
  sudo cat /home/postgres/hosts > /etc/hosts
  rm -f  /home/postgres/hosts
  echo "New hosts file :"
  sudo cat /etc/hosts
}

#Ensure the process to be up ...
/bin/bash &

#Define the database with the new entry level script not for live ...
if [[ -z "$(ls -latr /var/lib/postgresql/data/ | grep postgresql.conf)" ]]; then
  sudo chmod -Rf 777 /postgres-entrypoint-initdb.d
  sudo chmod 700 /var/lib/postgresql/data
  if ! [[ -z "$POSTGRES_OS_USER" ]] && ! [[ -z "$POSTGRES_OS_GROUP" ]]; then
    sudo chown -R $POSTGRES_OS_USER:$POSTGRES_OS_GROUP /var/lib/postgresql/data
    echo "Initializing PostgresSQL as $POSTGRES_OS_USER ..."
    sudo su $POSTGRES_OS_USER "postgresql-entrypoint.sh postgres"
  else
    sudo chown -R postgres:postgres /var/lib/postgresql/data
    echo "Initializing PostgresSQL as postgres ..."
    postgresql-entrypoint.sh postgres
  fi
fi

function startPostgres {
  touch /var/log/postgresql/postgres.log
  if ! [[ -z "$POSTGRES_OS_USER" ]] && ! [[ -z "$POSTGRES_OS_GROUP" ]]; then
    echo "Starting server as $1 ..."
    sudo chown "$1":"$1" /var/log/postgresql/postgres.log
    sudo su "$1" -c "start-postgresql.sh"
  else
    echo "Starting server as postgres ..."
    sudo chown postgres:postgres /var/log/postgresql/postgres.log
    start-postgresql.sh
  fi
}

#Check Postgres come up and running ...
function getPostgresState {
  POSTGRES_UP="$(ps -eaf|grep postgres)"
  if [[ -z "$POSTGRES_UP" ]]; then
    eval "$1='false'"
  else
    eval "$1='true'"
  fi
}

#Stop Postgres ...
function stopPostgres {
  if ! [[ -z "$POSTGRES_OS_USER" ]] && ! [[ -z "$POSTGRES_OS_GROUP" ]]; then
    echo "Stopping server as $1 ..."
    sudo su "$1" -c "stop-postgresql.sh"
  else
    echo "Stopping server as postgres ..."
    stop-postgresql.sh
  fi
}

#Check Postgres come up and running ...
function checkPostgresIsUp {
  COUNTER=0
  echo "Waiting for Postgres to be up and running ..."
  POSTGRES_UP=""
  getPostgresState POSTGRES_UP
  while [[ "true" != "$POSTGRES_UP" && $COUNTER -lt 20 ]]
  do
    sleep 5
    echo "Waiting for Postgres to be up and running ..."
    getPostgresState POSTGRES_UP
    let COUNTER=COUNTER+1
  done
}
if [[ -z "$(sudo cat /etc/passwd | grep $POSTGRES_USER)" ]]; then
  echo "Pre-Ansible: Defining user and rights for $POSTGRES_USER ..."
  sudo useradd --create-home --home-dir /home/$POSTGRES_USER --password $POSTGRES_PASSWORD $POSTGRES_USER
  sudo groupadd sudoers
  sudo usermod -aG ssh $POSTGRES_USER
  sudo usermod -aG sudoers $POSTGRES_USER
  sudo usermod -aG ssh root
  sudo usermod -aG sudoers root
  sudo su root -c "cp /etc/sudoers /home/postgres/sudoers && chmod 777 /home/postgres/sudoers &&  echo \"$POSTGRES_USER  ALL=(ALL) NOPASSWD:ALL\" >> /home/postgres/sudoers && chmod 400 /home/postgres/sudoers && cat /home/postgres/sudoers > /etc/sudoers && rm -f /home/postgres/sudoers"
fi
if ! [[ -z "$POSTGRES_OS_USER" ]] && [[ "$POSTGRES_USER" != "$POSTGRES_OS_USER" ]]; then
  sudo su root -c "cp /etc/sudoers /home/postgres/sudoers && chmod 777 /home/postgres/sudoers &&  echo \"$POSTGRES_OS_USER  ALL=(ALL) NOPASSWD:ALL\" >> /home/postgres/sudoers && chmod 400 /home/postgres/sudoers && cat /home/postgres/sudoers > /etc/sudoers && rm -f /home/postgres/sudoers"
fi

#Check pre-start Postgres ...
if [[ "true" == "$PRESTART_POSTGRES" ]]; then
  echo "Pre-Ansible: Starting Postgres ..."
  startPostgres
  checkPostgresIsUp
fi

PREPARED="$(ls /usr/local/share/ansible/playbook/.prepared)"

#Prepare security and templates and then clone and checkout the repos  ...
if [[ -z "$PREPARED" ]]; then
  export CURRPWD="$PWD"
  if ! [[ -z "$PRIVATE_PUBLIC_KEY_TAR_URL" ]]; then
    echo "Importing private/public keys from tar file ..."
    wget "$PRIVATE_PUBLIC_KEY_TAR_URL" -O /home/postgres/keys.tar
    if [[ -e /home/postgres/keys.tar ]]; then
      echo "decompressing in .ssh path ..."
      mkdir -p /home/postgres/.ssh
      cd /home/postgres/.ssh
      tar -xvf ../keys.tar
      rm -f /home/postgres/keys.tar
      chmod 600 -f /home/postgres/.ssh/id_rsa*
      cd $CURRPWD
    fi
  else
    echo "No key tar file specified or invalid url ..."
  fi

  echo "+---------------------------------------------------------------+"
  echo "| New Commands available :                                      |"
  echo "| - Stop PostgreSQL without exit :                              |"
  echo "|   stop-postgresql.sh                                          |"
  echo "| - Start PostgreSQL :                                          |"
  echo "|   start-postgresql.sh                                         |"
  echo "+---------------------------------------------------------------+"
  configuringHosts
  cp $PLAYBOOK_FOLDER/inventory/localhost $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME
  echo "$ANSIBLE_HOSTNAME      ansible_connection=local" >> $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME
  #Defining your credential for postgres
  git config --global --add user.name $USER_NAME
  git config --global --add user.email $USER_EMAIL
  #As postgres we clone the 'main' repo and than we give grants to postgres, removing the .git folder, no remote interaction allowed
  git clone $MAIN_REPO_URL $PLAYBOOK_FOLDER/main && cd $PLAYBOOK_FOLDER/main && git checkout $MAIN_REPO_BRANCH && git fetch && rm -Rf .git
  cd $PLAYBOOK_FOLDER
  #Here we simply ridefine the ansible.cfg, in a real world we should che the existing and changing parammeters in, no time just right now
  PARSED_FOLDER="$(echo "$ROLES_REPO_FOLDER" | sed 's/\//\\\//g' )"
  sed -e "s/ROLES_PATH/\/usr\/local\/share\/ansible\/playbook\/roles\/$PARSED_FOLDER/g" $PLAYBOOK_FOLDER/template/ansible.cfg > $PLAYBOOK_FOLDER/main/$MAIN_REPO_FOLDER/ansible.cfg
  #As postgres we clone the 'roles' repo and than we give grants to postgres, removing the .git folder, no remote interaction allowed
  git clone $ROLES_REPO_URL $PLAYBOOK_FOLDER/roles && cd $PLAYBOOK_FOLDER/roles && git checkout $ROLES_REPO_BRANCH && git fetch && rm -Rf .git
  cd $PLAYBOOK_FOLDER
  #Fake prepare of variables, we can improve this section adding a seeding variable
  cp $PLAYBOOK_FOLDER/template/vars $PLAYBOOK_FOLDER/
  # Removing credential due to a distribution security issues
  # Credential should be defined in the ansible and
  # Specific Postgres ones, at all
  git config --global --unset user.name
  git config --global --unset user.email
  rm -f /home/postgres/.ssh/id_rsa*
  touch $PLAYBOOK_FOLDER/.prepared
fi

INSTALLED="$(ls /usr/local/share/ansible/playbook/.installed)"
FAILED=""
#Starting the ansible playbooks ...
if [[ -z "$INSTALLED" ]]; then
  echo "Installation of playbooks in progress ..."
  cd $PLAYBOOK_FOLDER/main/$MAIN_REPO_FOLDER
  echo "Playbooks Installation folder: $PWD"
  for i in ${PLAYBOOKS//,/ }
    do
        VALID="$( if [[ -e ./$i.yml ]]; then echo 'true'; else echo 'false'; fi )"
        echo "Now playing file: $PLAYBOOK_FOLDER/main/$MAIN_REPO_FOLDER/$i.yml - valid : $VALID"
        if [[ -e ./$i.yml ]]; then
          echo "INSTALLING PLAYBOOK : $i.yml"
          ansible-playbook -i $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME -e @vars -e @inputs -e @private -e @$PLAYBOOK_FOLDER/vars ./$i.yml
        else
          FAILED="1"
          echo "Required playbook $i.yml doesn't exist ..."
        fi
    done
  cd $PLAYBOOK_FOLDER
  if [[ -z "$FAILED" ]]; then
    touch $PLAYBOOK_FOLDER/.installed
  fi
fi
#Check and define the hostname ....
MACHINE_HOST="$(hostname)"
if [[ "$HOSTNAME.$RIGLETDOMAIN" != "$MACHINE_HOST" ]]; then
  configuringHosts
  echo "Setting up host to $HOSTNAME.$RIGLETDOMAIN ..."
  sudo hostname $HOSTNAME.$RIGLETDOMAIN
fi


echo "All done!!"

#Check re-start Postgres ....
if [[ "true" == "$RESTART_POSTGRES_AFTER_ANSIBLE" ]]; then
  echo "Post-Ansible: Restarting Postgres ..."
  stopPostgres
  startPostgres
  checkPostgresIsUp
fi
#Check Jenkins logs ....
if [[ -e /var/log/postgresql/postgres.log ]]; then
  tail -f /var/log/postgresql/postgres.log
fi

#Wait forever ....
touch $PLAYBOOK_FOLDER/.watchfile
sudo chown postgres:postgres $PLAYBOOK_FOLDER/.watchfile
watch -n 86400 $PLAYBOOK_FOLDER/.watchfile

echo "Leaving file $PLAYBOOK_FOLDER/run_ansible_playbook.sh ..."
