#!/bin/bash
PLAYBOOK_FOLDER="/usr/local/share/ansible/playbook"

#Ensure the process to be up ...
/bin/bash &

#Check pre-start SonarQube ...
if [[ "true" == "$PRESTART_SONARQUBE" ]]; then
  echo "Pre-Ansible: Starting SonarQube ..."
  startSonarQube
  checkSonarQubeIsUp
fi

function startSonarQube {
  # RUN_AS_USER=root
  start-sonarqube.sh
}

function stopSonarQube {
  # RUN_AS_USER=root
  stop-sonarqube.sh
}

function restartSonarQube {
  RUNNING="false"
  isSonarQubeRunning RUNNING
  if [[ "true" == "$RUNNING" ]]; then
    stopSonarQube
    startSonarQube
  else
    startSonarQube
  fi
}

function isSonarQubeRunning {
  RUNNING="$(curl -I  --stderr /dev/null curl http://localhost:9000$SONARQUBE_ANSIBLE_DEFINED_CONTEXT_PATH/about | head -1 | cut -d' ' -f2)"
  if [[ "200" != "$RUNNING" ]]; then
    eval "$1='false'"
  else
    eval "$1='true'"
  fi
}

function getSonarQubeState {
  eval "$1=\"$( curl -I  --stderr /dev/null curl http://localhost:9000$SONARQUBE_ANSIBLE_DEFINED_CONTEXT_PATH/about | head -1 | cut -d' ' -f2 )\""
}

#Check SonarQube come up and running ...
function checkSonarQubeIsUp {
  COUNTER=0
  echo "Waiting for SonarQube to be up and running ..."
  SONARQUBE_UP="$(curl -I  --stderr /dev/null curl http://localhost:9000$SONARQUBE_ANSIBLE_DEFINED_CONTEXT_PATH/about | head -1 | cut -d' ' -f2)"
  while [[ "200" != "$SONARQUBE_UP" && $COUNTER -lt 18 ]]
  do
    sleep 10
    echo "Waiting for SonarQube to be up and running ..."
    SONARQUBE_UP="$(curl -I  --stderr /dev/null curl http://localhost:9000$SONARQUBE_ANSIBLE_DEFINED_CONTEXT_PATH/about | head -1 | cut -d' ' -f2)"
    let COUNTER=COUNTER+1
  done
}


PREPARED="$(ls /usr/local/share/ansible/playbook/.prepared)"

#Prepare security and templates and then clone and checkout the repos  ...
if [[ -z "$PREPARED" ]]; then
  export CURRPWD="$PWD"
  if ! [[ -z "$PRIVATE_PUBLIC_KEY_TAR_URL" ]]; then
    echo "Importing private/public keys from tar file ..."
    wget "$PRIVATE_PUBLIC_KEY_TAR_URL" -O /root/keys.tar
    if [[ -e /root/keys.tar ]]; then
      echo "decompressing in .ssh path ..."
      mkdir -p /root/.ssh
      cd /root/.ssh
      tar -xvf ../keys.tar
      rm -f /root/keys.tar
      chmod 600 -f /root/.ssh/id_rsa*
      cd $CURRPWD
    fi
  else
    echo "No key tar file specified or invalid url ..."
  fi

  echo "+---------------------------------------------------------------+"
  echo "| New Commands available :                                      |"
  echo "| - Start SonarQube :                                           |"
  echo "|   start-sonarqube.sh                                          |"
  echo "| - Stop SonarQube without exit :                               |"
  echo "|   stop-sonarqube.sh                                           |"
  echo "| - SonarQube status [on/off] command :                         |"
  echo "|   sonarqube-status.sh                                         |"
  echo "+---------------------------------------------------------------+"
  echo "Starting SonarQube Ansible Playbooks ..."
  echo "Configuring ansible host to : $ANSIBLE_HOSTNAME"
  echo "Configuring machine host to : $HOSTNAME"
  echo "Configuring machine riglet domain to : $RIGLETDOMAIN"
  cat /etc/hosts > /root/hosts
  echo "127.0.0.1  localhost localhost.localdomain localhost.$RIGLETDOMAIN" >> /root/hosts
  echo "127.0.0.1  $HOSTNAME   $HOSTNAME.$RIGLETDOMAIN" >> /root/hosts
  cat /root/hosts > /etc/hosts
  rm -f  /root/hosts
  echo "New hosts file :"
  cat /etc/hosts
  cp $PLAYBOOK_FOLDER/inventory/localhost $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME
  echo "$ANSIBLE_HOSTNAME      ansible_connection=local" >> $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME
  #Defining your credential for jenkins
  git config --global --add user.name $USER_NAME
  git config --global --add user.email $USER_EMAIL
  #As jenkins we clone the 'main' repo and than we give grants to jenkins, removing the .git folder, no remote interaction allowed
  git clone $MAIN_REPO_URL $PLAYBOOK_FOLDER/main && cd $PLAYBOOK_FOLDER/main && git checkout $MAIN_REPO_BRANCH && git fetch && rm -Rf .git
  cd $PLAYBOOK_FOLDER
  #Here we simply ridefine the ansible.cfg, in a real world we should che the existing and changing parammeters in, no time just right now
  PARSED_FOLDER="$(echo "$ROLES_REPO_FOLDER" | sed 's/\//\\\//g' )"
  sed -e "s/ROLES_PATH/\/usr\/local\/share\/ansible\/playbook\/roles\/$PARSED_FOLDER/g" $PLAYBOOK_FOLDER/template/ansible.cfg > $PLAYBOOK_FOLDER/main/$MAIN_REPO_FOLDER/ansible.cfg
  #As jenkins we clone the 'roles' repo and than we give grants to jenkins, removing the .git folder, no remote interaction allowed
  git clone $ROLES_REPO_URL $PLAYBOOK_FOLDER/roles && cd $PLAYBOOK_FOLDER/roles && git checkout $ROLES_REPO_BRANCH && git fetch && rm -Rf .git
  cd $PLAYBOOK_FOLDER
  #Fake prepare of variables, we can improve this section adding a seeding variable
  cp $PLAYBOOK_FOLDER/template/vars $PLAYBOOK_FOLDER/
  # Removing credential due to a distribution security issues
  # Credential should be defined in the ansible and
  # Specific SonarQube ones, at all
  git config --global --unset user.name
  git config --global --unset user.email
  rm -f /root/.ssh/id_rsa*
  touch $PLAYBOOK_FOLDER/.prepared
fi

INSTALLED="$(ls /usr/local/share/ansible/playbook/.installed)"
FAILED=""
#Starting the ansible playbooks ...
if [[ -z "$INSTALLED" ]]; then
  echo "Installation of roles in progress ..."
  cd $PLAYBOOK_FOLDER/main/$MAIN_REPO_FOLDER
  echo "Playbooks Installation forlder: $PWD"
  for i in ${PLAYBOOKS//,/ }
    do
        if [[ -e $PLAYBOOK_FOLDER/main/$MAIN_REPO_FOLDER/$i.yml ]]; then
          echo "INSTALLING PLAYBOOK : $i.yml"
          ansible-playbook -i $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME -e @vars -e @inputs -e @private -e @$PLAYBOOK_FOLDER/vars ./$i.yml
        else
          FAILED="1"
          echo "Required role $i.yml doesn't exist ..."
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
  echo "Setting up host to $HOSTNAME.$RIGLETDOMAIN ..."
  sudo hostname $HOSTNAME.$RIGLETDOMAIN
fi
echo "All done!!"
#Check post-start SonarQube ....
if [[ "true" != "$PRESTART_SONARQUBE" ]] && [[ "true" == "$POSTSTART_SONARQUBE" ]]; then
  STATE=""
  getSonarQubeState STATE
  if [[ "200" !=  "$STATE" ]]; then
    echo "Post-Ansible: Starting SonarQube ..."
    startSonarQube
    checkSonarQubeIsUp
  else
    if [[ "true" != "$RESTART_SONARQUBE_AFTER_ANSIBLE" ]]; then
        if [[ "true" == "$PRESTART_SONARQUBE_IF_UP_POST_ANSIBLE" ]]; then
          echo "Post-Ansible: Server up!! Restarting SonarQube instead of Start-Up ..."
          restartSonarQube
          checkSonarQubeIsUp
        else
          echo "Post-Ansible: No start to apply, PRESTART_SONARQUBE_IF_UP_POST_ANSIBLE=$PRESTART_SONARQUBE_IF_UP_POST_ANSIBLE"
        fi
    else
      echo "Post-Ansible: No start to apply, waiting for SonarQube Restart ..."
    fi
  fi;
fi

#Check re-start SonarQube ....
if [[ "true" == "$RESTART_SONARQUBE_AFTER_ANSIBLE" ]]; then
  echo "Post-Ansible: Restarting SonarQube ..."
  restartSonarQube
  checkSonarQubeIsUp
fi

echo "SonarQube Ansible playbooks completed!!"


#Check Nexus logs ....
if [[ -e $SONARQUBE_HOME/logs/sonarqube.log ]]; then
  tail -f $SONARQUBE_HOME/logs/sonarqube.log
fi

#Wait forever ....
touch $PLAYBOOK_FOLDER/.watchfile
watch -n 86400 $PLAYBOOK_FOLDER/.watchfile

echo "Leaving file $PLAYBOOK_FOLDER/run_ansible_playbook.sh ..."
