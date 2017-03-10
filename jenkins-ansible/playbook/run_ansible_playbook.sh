#!/bin/bash

PREPARED="$(ls /usr/local/share/ansible/playbook/.prepared)"

if [[ -z "$PREPARED" ]]; then
  echo "Removing private key ..."
  rm -f /root/.ssh/id_rsa
  echo "Removing public key ..."
  rm -f /root/.ssh/id_rsa.pub
  export CURRPWD="$PWD"
  if ! [[ -z "$PRIVATE_PUBLIC_KEY_TAR_URL" ]]; then
    echo "Importing private/public key ..."
    wget "$PRIVATE_PUBLIC_KEY_TAR_URL" -O /root/keys.tar
    if [[ -e /root/keys.tar ]]; then
      echo "decompressing in .ssh path ..."
      cd /root/.ssh
      tar -xvf ../keys.tar
      rm -f /root/keys.tar
      cd $CURRPWD
    fi
  else
    echo "Removing private key ..."
    rm -f /root/.ssh/id_rsa
    echo "Removing public key ..."
    rm -f /root/.ssh/id_rsa.pub
  fi
  if ! [[ -z "$PLUGIN_TEXT_FILE_URL" ]]; then
    echo "Importing plugins text file ..."
    wget "$PLUGINS_TEXT_FILE_URL" -O /usr/share/jenkins/ref/plugins.txt
    if [[ -e /usr/share/jenkins/ref/plugins.txt ]]; then
      /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt
    fi
  fi
#  ansible-playbook -c local -i ./inventory/localhost  playbook.yml
  echo "Configuring ansible host to : $ANSIBLE_HOSTNAME"
  echo "Configuring machine host to : $HOSTNAME"
  echo "Configuring machine riglet domain to : $RIGLETDOMAIN"
  echo "127.0.0.1  $HOSTNAME   $HOSTNAME.$RIGLETDOMAIN" > /etc/hosts
  hostname $HOSTNAME
  cp ./inventory/localhost ./inventory/$ANSIBLE_HOSTNAME
  echo "$ANSIBLE_HOSTNAME      ansible_connection=local" >> ./inventory/$ANSIBLE_HOSTNAME
  git config --global --add user.name $USER_NAME
  git config --global --add user.email $USER_EMAIL
  git clone $MAIN_REPO_URL main
  cd main
  git checkout $MAIN_REPO_BRANCH
  git fetch
  git pull
  rm -Rf .git
  cd ../
  cp -f ./template/ansible.cfg ./main/$MAIN_REPO_FOLDER/
  git clone $ROLES_REPO_URL roles
  cd roles
  git checkout $ROLES_REPO_BRANCH
  git fetch
  git pull
  rm -Rf .git
  cd ..
  # cp ./template/playbook.yml ./
  # for i in ${PLAYBOOKS//,/ }
  #   do
  #       echo "  - $i.yml" >> ./playbook.yml
  #   done
  #Fake prepare of variables
  cp ./template/vars ./
  touch ./.prepared
fi

INSTALLED="$(ls /usr/local/share/ansible/playbook/.installed)"
FAILED=""
if [[ -z "$INSTALLED" ]]; then
#  ansible-playbook -c local -i ./inventory/localhost  playbook.yml
  echo "Installation of roles in progress ..."
  cd ./main/$MAIN_REPO_FOLDER
  for i in ${PLAYBOOKS//,/ }
    do
        if [[ -e ./$i.yml ]]; then
          ansible-playbook -i /usr/local/share/ansible/playbook/inventory/$ANSIBLE_HOSTNAME -e @vars -e @inputs -e @private -e @/usr/local/share/ansible/playbook/vars ./$i.yml
        else
          FAILED="1"
          echo "Required role $i.yml doesn't exist ..."
        fi
        echo "  - $i.yml" >> ./playbook.yml
    done
  if [[ -z "$FAILED" ]]; then
    touch ./.installed
  fi
fi
echo "All done!!"
sudo su jenkins
jenkins.sh &
sleep 20
tail -f /var/log/jenkins/jenkins.log
