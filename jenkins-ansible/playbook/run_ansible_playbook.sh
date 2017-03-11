#!/bin/bash
PLAYBOOK_FOLDER="/usr/local/share/ansible/playbook"

#Ensure the process to be up ...
/bin/bash &

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

PREPARED="$(ls /usr/local/share/ansible/playbook/.prepared)"

if [[ -z "$PREPARED" ]]; then
  echo "Removing private key ..."
  rm -f /home/jenkins/.ssh/id_rsa
  echo "Removing public key ..."
  rm -f /home/jenkins/.ssh/id_rsa.pub
  export CURRPWD="$PWD"
  if ! [[ -z "$PRIVATE_PUBLIC_KEY_TAR_URL" ]]; then
    echo "Importing private/public key ..."
    wget "$PRIVATE_PUBLIC_KEY_TAR_URL" -O /home/jenkins/keys.tar
    if [[ -e /home/jenkins/keys.tar ]]; then
      echo "decompressing in .ssh path ..."
      cd /home/jenkins/.ssh
      tar -xvf ../keys.tar
      rm -f /home/jenkins/keys.tar
      sudo cp /home/jenkins/.ssh/* /root/.ssh/
      cd $CURRPWD
    fi
  else
    echo "Removing private key ..."
    rm -f /home/jenkins/.ssh/id_rsa
    echo "Removing public key ..."
    rm -f /home/jenkins/.ssh/id_rsa.pub
  fi
  echo "prepare command for jenkins stop ..."

  echo "#!/bin/bash" > /home/jenkins/stop-jenkins.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /home/jenkins/stop-jenkins.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ safe-shutdown 2> /dev/null" >> /home/jenkins/stop-jenkins.sh
  echo "else" >> /home/jenkins/stop-jenkins.sh
  echo "  echo 'Client jar not found ...'" >> /home/jenkins/stop-jenkins.sh
  echo "  exit 1" >> /home/jenkins/stop-jenkins.sh
  echo "fi" >> /home/jenkins/stop-jenkins.sh
  echo "exit 0" >> /home/jenkins/stop-jenkins.sh
  sudo mv /home/jenkins/stop-jenkins.sh /usr/local/bin/stop-jenkins.sh

  echo "#!/bin/bash" > /home/jenkins/restart-jenkins.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /home/jenkins/restart-jenkins.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ safe-restart 2> /dev/null" >> /home/jenkins/restart-jenkins.sh
  echo "else" >> /home/jenkins/restart-jenkins.sh
  echo "  echo 'Client jar not found ...'" >> /home/jenkins/restart-jenkins.sh
  echo "  exit 1" >> /home/jenkins/restart-jenkins.sh
  echo "fi" >> /home/jenkins/restart-jenkins.sh
  echo "exit 0" >> /home/jenkins/restart-jenkins.sh
  sudo mv /home/jenkins/restart-jenkins.sh /usr/local/bin/restart-jenkins.sh

  echo "#!/bin/bash" > /home/jenkins/execute-cli-file-command.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /home/jenkins/execute-cli-file-command.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ \${@:2} < \$1" >> /home/jenkins/execute-cli-file-command.sh
  echo "else" >> /home/jenkins/execute-cli-file-command.sh
  echo "  echo 'Client jar not found ...'" >> /home/jenkins/execute-cli-file-command.sh
  echo "  exit 1" >> /home/jenkins/execute-cli-file-command.sh
  echo "fi" >> /home/jenkins/execute-cli-file-command.sh
  echo "exit 0" >> /home/jenkins/execute-cli-file-command.sh
  sudo mv /home/jenkins/execute-cli-file-command.sh /usr/local/bin/execute-cli-file-command.sh

  echo "#!/bin/bash" > /home/jenkins/execute-cli-command.sh
  echo "if [[ -e /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]]; then" >> /home/jenkins/execute-cli-command.sh
  echo "  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ \$@" >> /home/jenkins/execute-cli-command.sh
  echo "else" >> /home/jenkins/execute-cli-command.sh
  echo "  echo 'Client jar not found ...'" >> /home/jenkins/execute-cli-command.sh
  echo "  exit 1" >> /home/jenkins/execute-cli-command.sh
  echo "fi" >> /home/jenkins/execute-cli-command.sh
  echo "exit 0" >> /home/execute-cli-command.sh
  sudo mv /home/jenkins/execute-cli-command.sh /usr/local/bin/execute-cli-command.sh

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
  sudo cat /etc/hosts > /home/jenkins/hosts
  sudo chown jenkins:jenkins /home/jenkins/hosts
  echo "127.0.0.1  localhost localhost.localdomain localhost.$RIGLETDOMAIN" >> /home/jenkins/hosts
  echo "127.0.0.1  $HOSTNAME   $HOSTNAME.$RIGLETDOMAIN" >> /home/jenkins/hosts
  sudo su -c "cat /home/jenkins/hosts > /etc/hosts"
  rm -f  /home/jenkins/hosts
  echo "New hosts file :"
  sudo cat /etc/hosts
  cp $PLAYBOOK_FOLDER/inventory/localhost $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME
  echo "$ANSIBLE_HOSTNAME      ansible_connection=local" >> $PLAYBOOK_FOLDER/inventory/$ANSIBLE_HOSTNAME
  sudo git config --global --add user.name $USER_NAME
  sudo git config --global --add user.email $USER_EMAIL
  sudo su root -c "git clone $MAIN_REPO_URL $PLAYBOOK_FOLDER/main && cd $PLAYBOOK_FOLDER/main && git checkout $MAIN_REPO_BRANCH && git fetch && sudo git pull && rm -Rf .git"
  cd $PLAYBOOK_FOLDER
  sudo chown -Rf jenkins:jenkins $PLAYBOOK_FOLDER/main
  PARSED_FOLDER="$(echo "$ROLES_REPO_FOLDER" | sed 's/\//\\\//g' )"
  sed -e "s/ROLES_PATH/\/usr\/local\/share\/ansible\/playbook\/roles\/$PARSED_FOLDER/g" $PLAYBOOK_FOLDER/template/ansible.cfg > $PLAYBOOK_FOLDER/main/$MAIN_REPO_FOLDER/ansible.cfg
  # sudo git clone $ROLES_REPO_URL $PLAYBOOK_FOLDER/roles
  # sudo cd $PLAYBOOK_FOLDER/roles
  # sudo git checkout $ROLES_REPO_BRANCH
  # sudo git fetch
  # sudo git pull
  # sudo rm -Rf .git
  sudo su root -c "git clone $ROLES_REPO_URL $PLAYBOOK_FOLDER/roles && cd $PLAYBOOK_FOLDER/roles && git checkout $ROLES_REPO_BRANCH && git fetch && sudo git pull && rm -Rf .git"
  cd $PLAYBOOK_FOLDER
  sudo chown -Rf jenkins:jenkins $PLAYBOOK_FOLDER/roles
  #Fake prepare of variables
  cp $PLAYBOOK_FOLDER/template/vars $PLAYBOOK_FOLDER/
  touch $PLAYBOOK_FOLDER/.prepared
fi

INSTALLED="$(ls /usr/local/share/ansible/playbook/.installed)"
FAILED=""
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
MACHINE_HOST="$(hostname)"
if [[ "$HOSTNAME.$RIGLETDOMAIN" != "$MACHINE_HOST" ]]; then
  echo "Setting up host to $HOSTNAME.$RIGLETDOMAIN ..."
  sudo hostname $HOSTNAME.$RIGLETDOMAIN
fi
echo "All done!!"
echo "Starting Jenkins ..."
jenkins.sh &
checkJenkinsIsUp
if [[ -e /var/log/jenkins/jenkins.log ]]; then
  tail -f /var/log/jenkins/jenkins.log
fi

watch -n 86400 $PLAYBOOK_FOLDER/run_ansible_playbook.sh
echo "Exit for Jenkins Container ..."
