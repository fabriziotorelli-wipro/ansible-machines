#!/bin/bash
PLAYBOOK_FOLDER="/usr/local/share/ansible/playbook"

#Ensure the process to be up ...
/bin/bash &

#Check pre-start Nexus ...
if [[ "true" == "$PRESTART_NEXUS" ]]; then
  echo "Pre-Ansible: Starting Nexus ..."
  startNexus
  checkNexusIsUp
fi


function configuringHosts {
  echo "Configuring ansible host to : $ANSIBLE_HOSTNAME"
  echo "Configuring machine host to : $HOSTNAME"
  echo "Configuring machine riglet domain to : $RIGLETDOMAIN"
  sudo cat /etc/hosts > /sonatype-work/hosts
  sudo chown nexus:nexus /sonatype-work/hosts
  echo "127.0.0.1  localhost localhost.localdomain localhost.$RIGLETDOMAIN" >> /sonatype-work/hosts
  echo "127.0.0.1  $HOSTNAME   $HOSTNAME.$RIGLETDOMAIN" >> /sonatype-work/hosts
  sudo chmod 777 /etc/hosts
  sudo cat /sonatype-work/hosts > /etc/hosts
  rm -f  /sonatype-work/hosts
  echo "New hosts file :"
  sudo cat /etc/hosts
}

function startNexus {
  # RUN_AS_USER=root
  nexus start
}

function stopNexus {
  # RUN_AS_USER=root
  nexus stop
}

function restartNexus {
  RUNNING="false"
  isNexusRunning RUNNING
  if [[ "true" == "$RUNNING" ]]; then
    stopNexus
    startNexus
  else
    startNexus
  fi
}

function getNexusState {
  eval "$1=\"$( curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2 )\""
}

function isNexusRunning {
  RUNNING="$( curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2 )"
  if [[ "200" != "$RUNNING" ]]; then
    eval "$1='false'"
  else
    eval "$1='true'"
  fi
}

#Check Nexus come up and running ...
function checkNexusIsUp {
  COUNTER=0
  echo "Waiting for Nexus to be up and running ..."
  NEXUS_UP="$(curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2)"
  while [[ "200" != "$NEXUS_UP" && $COUNTER -lt 18 ]]
  do
    sleep 10
    echo "Waiting for Nexus to be up and running ..."
    NEXUS_UP="$(curl -I  --stderr /dev/null curl http://localhost:8081/nexus/service/local/status | head -1 | cut -d' ' -f2)"
    let COUNTER=COUNTER+1
  done
}


PREPARED="$(ls /usr/local/share/ansible/playbook/.prepared)"

#Prepare security and templates and then clone and checkout the repos  ...
if [[ -z "$PREPARED" ]]; then
  export CURRPWD="$PWD"
  if ! [[ -z "$PRIVATE_PUBLIC_KEY_TAR_URL" ]]; then
    echo "Importing private/public keys from tar file ..."
    wget "$PRIVATE_PUBLIC_KEY_TAR_URL" -O /sonatype-work/keys.tar
    if [[ -e /sonatype-work/keys.tar ]]; then
      echo "decompressing in .ssh path ..."
      mkdir -p /sonatype-work/.ssh
      cd /sonatype-work/.ssh
      tar -xvf ../keys.tar
      rm -f /sonatype-work/keys.tar
      chmod 600 -f /sonatype-work/.ssh/id_rsa*
      cd $CURRPWD
    fi
  else
    echo "No key tar file specified or invalid url ..."
  fi
  # echo "prepare command for jenkins java client interaction ..."

  sudo mv $PLAYBOOK_FOLDER/is-running-nexus.sh /usr/local/bin/is-running-nexus.sh
  sudo mv $PLAYBOOK_FOLDER/stop-nexus.sh /usr/local/bin/stop-nexus.sh
  sudo mv $PLAYBOOK_FOLDER/start-nexus.sh /usr/local/bin/start-nexus.sh
  sudo mv $PLAYBOOK_FOLDER/restart-nexus.sh /usr/local/bin/restart-nexus.sh

  sudo chmod 777 /usr/local/bin/is-running-nexus.sh
  sudo chmod 777 /usr/local/bin/stop-nexus.sh
  sudo chmod 777 /usr/local/bin/start-nexus.sh
  sudo chmod 777 /usr/local/bin/restart-nexus.sh

  echo "+---------------------------------------------------------------+"
  echo "| New Commands available :                                      |"
  echo "| - Check Nexus JVM running :                                   |"
  echo "|   is-running-nexus.sh                                         |"
  echo "| - Restart Nexus without exit :                                |"
  echo "|   restart-nexus.sh                                            |"
  echo "| - Start Nexus command :                                       |"
  echo "|   start-nexus.sh                                              |"
  echo "| - Stop Nexus  without exit :                                  |"
  echo "|   stop-nexus.sh                                               |"
  echo "+---------------------------------------------------------------+"
  echo "Starting Nexus Ansible Playbooks ..."
  configuringHosts
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
  # Specific Nexus ones, at all
  git config --global --unset user.name
  git config --global --unset user.email
  rm -f /sonatype-work/.ssh/id_rsa*
  touch $PLAYBOOK_FOLDER/.prepared
fi

INSTALLED="$(ls /usr/local/share/ansible/playbook/.installed)"
FAILED=""
#Starting the ansible playbooks ...
if [[ -z "$INSTALLED" ]]; then
  echo "Installation of playbooks in progress ..."
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
  configuringHosts
  echo "Setting up host to $HOSTNAME.$RIGLETDOMAIN ..."
  sudo hostname $HOSTNAME.$RIGLETDOMAIN
fi
echo "All done!!"
#Check post-start Nexus ....
if [[ "true" != "$PRESTART_NEXUS" ]] && [[ "true" == "$POSTSTART_NEXUS" ]]; then
  STATE=""
  getNexusState STATE
  if [[ "200" !=  "$STATE" ]]; then
    echo "Post-Ansible: Starting Nexus ..."
    startNexus
    checkNexusIsUp
  else
    if [[ "true" != "$RESTART_NEXUS_AFTER_ANSIBLE" ]]; then
        if [[ "true" == "$PRESTART_NEXUS_IF_UP_POST_ANSIBLE" ]]; then
          echo "Post-Ansible: Server up!! Restarting Nexus instead of Start-Up ..."
          restartNexus
          checkNexusIsUp
        else
          echo "Post-Ansible: No start to apply, PRESTART_NEXUS_IF_UP_POST_ANSIBLE=$PRESTART_NEXUS_IF_UP_POST_ANSIBLE"
        fi
    else
      echo "Post-Ansible: No start to apply, waiting for Nexus Restart ..."
    fi
  fi
fi

#Check re-start Nexus ....
if [[ "true" == "$RESTART_NEXUS_AFTER_ANSIBLE" ]]; then
  echo "Post-Ansible: Restarting Nexus ..."
  restartNexus
  checkNexusIsUp
fi

#Check Nexus logs ....
if [[ -e /opt/sonatype/nexus/logs/wrapper.log ]]; then
  tail -f /opt/sonatype/nexus/logs/wrapper.log
fi

#Wait forever ....
touch $PLAYBOOK_FOLDER/.watchfile
watch -n 86400 $PLAYBOOK_FOLDER/.watchfile

echo "Leaving file $PLAYBOOK_FOLDER/run_ansible_playbook.sh ..."
