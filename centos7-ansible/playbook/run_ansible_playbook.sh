#!/bin/bash
/usr/sbin/init

function configuringHosts {
  echo "Configuring ansible host to : $ANSIBLE_HOSTNAME"
  echo "Configuring machine host to : $HOSTNAME"
  echo "Configuring machine riglet domain to : $RIGLETDOMAIN"
  sudo cat /etc/hosts > /root/hosts
  sudo chown jenkins:jenkins /root/hosts
  echo "127.0.0.1  localhost localhost.localdomain localhost.$RIGLETDOMAIN" >> /root/hosts
  echo "127.0.0.1  $HOSTNAME   $HOSTNAME.$RIGLETDOMAIN" >> /root/hosts
  sudo chmod 777 /etc/hosts
  sudo cat /root/hosts > /etc/hosts
  rm -f  /root/hosts
  echo "New hosts file :"
  sudo cat /etc/hosts
}

PREPARED="$(ls /opt/ansible/playbook/.prepared)"
if [[ -z "$PREPARED" ]]; then
#  ansible-playbook -c local -i ./inventory/localhost  playbook.yml
  configuringHosts
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

INSTALLED="$(ls /opt/ansible/playbook/.installed)"
FAILED=""
if [[ -z "$INSTALLED" ]]; then
#  ansible-playbook -c local -i ./inventory/localhost  playbook.yml
  echo "Installation of roles in progress ..."
  cd ./main/$MAIN_REPO_FOLDER
  for i in ${PLAYBOOKS//,/ }
    do
        if [[ -e ./$i.yml ]]; then
          ansible-playbook -i /opt/ansible/playbook/inventory/$ANSIBLE_HOSTNAME -e @vars -e @inputs -e @private -e @/opt/ansible/playbook/vars ./$i.yml
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

MACHINE_HOST="$(hostname)"
if [[ "$HOSTNAME.$RIGLETDOMAIN" != "$MACHINE_HOST" ]]; then
  configuringHosts
  echo "Setting up host to $HOSTNAME.$RIGLETDOMAIN ..."
  sudo hostname $HOSTNAME.$RIGLETDOMAIN
fi

#while (true) do sleep 86400; done
tail -f /opt/ansible/playbook/run_ansible_playbook.sh
#dr_scripts_ref
