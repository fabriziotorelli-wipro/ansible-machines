#!/bin/bash
PLAYBOOK_FOLDER="/usr/local/share/ansible/playbook"

#Ensure the process to be up ...
/bin/bash &

#Check pre-start Jenkins ...
if [[ "true" == "$PRESTART_JENKINS" ]]; then
  echo "Pre-Ansible: Starting Jenkins ..."
  jenkins.sh &
  checkJenkinsIsUp
fi


#Check Jenkins come up and running ...
function checkJenkinsIsUp {
  COUNTER=0
  echo "Waiting for Jenkins to be up and running ..."
  JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
  while [[ "200" != "$JENKINS_UP" && $COUNTER -lt 20 ]]
  do
    sleep 5
    echo "Waiting for Jenkins to be up and running ..."
    JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
    let COUNTER=COUNTER+1
  done
}

#Check Jenkins come up and running ...
function getJenkinsState {
  JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
  eval "$1=$JENKINS_UP"
}

PREPARED="$(ls /usr/local/share/ansible/playbook/.prepared)"

#Prepare security and templates and then clone and checkout the repos  ...
if [[ -z "$PREPARED" ]]; then
  export CURRPWD="$PWD"
  if ! [[ -z "$PRIVATE_PUBLIC_KEY_TAR_URL" ]]; then
    echo "Importing private/public keys from tar file ..."
    wget "$PRIVATE_PUBLIC_KEY_TAR_URL" -O /var/jenkins_home/keys.tar
    if [[ -e /var/jenkins_home/keys.tar ]]; then
      echo "decompressing in .ssh path ..."
      mkdir -p /var/jenkins_home/.ssh
      cd /var/jenkins_home/.ssh
      tar -xvf ../keys.tar
      rm -f /var/jenkins_home/keys.tar
      chmod 600 -f /var/jenkins_home/.ssh/id_rsa*
      cd $CURRPWD
    fi
  else
    echo "No key tar file specified or invalid url ..."
  fi
  echo "prepare command for jenkins java client interaction ..."

  echo "#!/bin/bash" > /var/jenkins_home/stop-jenkins.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /var/jenkins_home/stop-jenkins.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ safe-shutdown 2> /dev/null" >> /var/jenkins_home/stop-jenkins.sh
  echo "  exit \$?" >> /var/jenkins_home/stop-jenkins.sh
  echo "else" >> /var/jenkins_home/stop-jenkins.sh
  echo "  echo 'Client jar not found ...'" >> /var/jenkins_home/stop-jenkins.sh
  echo "  exit 1" >> /var/jenkins_home/stop-jenkins.sh
  echo "fi" >> /var/jenkins_home/stop-jenkins.sh
  sudo mv /var/jenkins_home/stop-jenkins.sh /usr/local/bin/stop-jenkins.sh

  echo "#!/bin/bash" > /var/jenkins_home/restart-jenkins.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /var/jenkins_home/restart-jenkins.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ safe-restart 2> /dev/null" >> /var/jenkins_home/restart-jenkins.sh
  echo "  exit \$?" >> /var/jenkins_home/stop-jenkins.sh
  echo "else" >> /var/jenkins_home/restart-jenkins.sh
  echo "  echo 'Client jar not found ...'" >> /var/jenkins_home/restart-jenkins.sh
  echo "  exit 1" >> /var/jenkins_home/restart-jenkins.sh
  echo "fi" >> /var/jenkins_home/restart-jenkins.sh
  sudo mv /var/jenkins_home/restart-jenkins.sh /usr/local/bin/restart-jenkins.sh

  echo "#!/bin/bash" > /var/jenkins_home/execute-cli-file-command.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /var/jenkins_home/execute-cli-file-command.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ \${@:2} < \$1" >> /var/jenkins_home/execute-cli-file-command.sh
  echo "  exit \$?" >> /var/jenkins_home/stop-jenkins.sh
  echo "else" >> /var/jenkins_home/execute-cli-file-command.sh
  echo "  echo 'Client jar not found ...'" >> /var/jenkins_home/execute-cli-file-command.sh
  echo "  exit 1" >> /var/jenkins_home/execute-cli-file-command.sh
  echo "fi" >> /var/jenkins_home/execute-cli-file-command.sh
  sudo mv /var/jenkins_home/execute-cli-file-command.sh /usr/local/bin/execute-cli-file-command.sh

  echo "#!/bin/bash" > /var/jenkins_home/execute-cli-command.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /var/jenkins_home/execute-cli-command.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ \$@" >> /var/jenkins_home/execute-cli-command.sh
  echo "  exit \$?" >> /var/jenkins_home/stop-jenkins.sh
  echo "else" >> /var/jenkins_home/execute-cli-command.sh
  echo "  echo 'Client jar not found ...'" >> /var/jenkins_home/execute-cli-command.sh
  echo "  exit 1" >> /var/jenkins_home/execute-cli-command.sh
  echo "fi" >> /var/jenkins_home/execute-cli-command.sh
  sudo mv /var/jenkins_home/execute-cli-command.sh /usr/local/bin/execute-cli-command.sh

  sudo chmod 777 /usr/local/bin/stop-jenkins.sh
  sudo chmod 777 /usr/local/bin/restart-jenkins.sh
  sudo chmod 777 /usr/local/bin/execute-cli-file-command.sh
  sudo chmod 777 /usr/local/bin/execute-cli-command.sh
  echo "+---------------------------------------------------------------+"
  echo "| New Commands available :                                      |"
  echo "| - Stop Jenkins without exit :                                 |"
  echo "|   stop-jenkins.sh                                             |"
  echo "| - Restart Jenkins without exit :                              |"
  echo "|   restart-jenkins.sh                                          |"
  echo "| - Execute Jenkins client command :                            |"
  echo "|   execute-cli-command.sh <command> <parameter>...            |"
  echo "| - Execute Jenkins client command with input file :            |"
  echo "|   execute-cli-command.sh <file-path> <command> <parameter>...|"
  echo "+---------------------------------------------------------------+"
  if ! [[ -z "$PLUGINS_TEXT_FILE_URL" ]]; then
    echo "Importing plugins text file ..."
    wget "$PLUGINS_TEXT_FILE_URL" -O /usr/share/jenkins/ref/plugins.txt
    if [[ -e /usr/share/jenkins/ref/plugins.txt ]]; then
      echo "Install plugins from text file ..."
      echo "Starting Jenkins"
      jenkins.sh &
      checkJenkinsIsUp
      echo "Running plugin procedure ..."
      cat /usr/share/jenkins/ref/plugins.txt | xargs /usr/local/bin/install-plugins.sh
      echo "Stopping Jenkins"
      /usr/local/bin/stop-jenkins.sh
    fi
  fi
  echo "Configuring ansible host to : $ANSIBLE_HOSTNAME"
  echo "Configuring machine host to : $HOSTNAME"
  echo "Configuring machine riglet domain to : $RIGLETDOMAIN"
  sudo cat /etc/hosts > /var/jenkins_home/hosts
  sudo chown jenkins:jenkins /var/jenkins_home/hosts
  echo "127.0.0.1  localhost localhost.localdomain localhost.$RIGLETDOMAIN" >> /var/jenkins_home/hosts
  echo "127.0.0.1  $HOSTNAME   $HOSTNAME.$RIGLETDOMAIN" >> /var/jenkins_home/hosts
  sudo su -c "cat /var/jenkins_home/hosts > /etc/hosts"
  rm -f  /var/jenkins_home/hosts
  echo "New hosts file :"
  sudo cat /etc/hosts
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
  # Specific Jenkins ones, at all
  git config --global --unset user.name
  git config --global --unset user.email
  rm -f /var/jenkins_home/.ssh/id_rsa*
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
#Check post-start Jenkins ....
if [[ "true" != "$PRESTART_JENKINS" ]]; then
  STATE=""
  getJenkinsState STATE
  if [[ "200" !=  "$STATE" ]]; then
    echo "Post-Ansible: Starting Jenkins ..."
    jenkins.sh &
    checkJenkinsIsUp
  else
    if [[ "true" != "$RESTART_JENKINS_AFTER_ANSIBLE" ]]; then
        if [[ "true" == "$PRESTART_JENKINS_IF_UP_POST_ANSIBLE" ]]; then
          echo "Post-Ansible: Server up!! Restarting Jenkins instead of Start-Up ..."
          /usr/local/bin/execute-cli-command.sh safe-restart
          checkJenkinsIsUp
        else
          echo "Post-Ansible: No start to apply, PRESTART_JENKINS_IF_UP_POST_ANSIBLE=$PRESTART_JENKINS_IF_UP_POST_ANSIBLE"
        fi
    else
      echo "Post-Ansible: No start to apply, waiting for Jenkins Restart ..."
    fi
  fi;
fi

#Check re-start Jenkins ....
if [[ "true" == "$RESTART_JENKINS_AFTER_ANSIBLE" ]]; then
  echo "Post-Ansible: Restarting Jenkins ..."
  /usr/local/bin/execute-cli-command.sh safe-restart
  checkJenkinsIsUp
fi

#Check Jenkins logs ....
if [[ -e /var/log/jenkins/jenkins.log ]]; then
  tail -f /var/log/jenkins/jenkins.log
else
  #Wait forever ....
  touch $PLAYBOOK_FOLDER/.watchfile
  watch -n 86400 $PLAYBOOK_FOLDER/.watchfile
fi

echo "Leaving file $PLAYBOOK_FOLDER/run_ansible_playbook.sh ..."
