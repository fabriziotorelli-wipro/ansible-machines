#!/bin/bash
PREPARED="$(ls /ansible/playbook/.prepared)"
if [[ -z "$PREPARED" ]]; then
#  ansible-playbook -c local -i ./inventory/localhost  playbook.yml
  git config --global --add user.name $USER_NAME
  git config --global --add user.email $USER_EMAIL
  git clone $MAIN_REPO_URL main
  cd main
  git checkout $MAIN_REPO_BRANCH
  git fetch
  git pull
  cd ../
  cp -f ./template/ansible.cfg ./main/$MAIN_REPO_FOLDER/
  git clone $ROLES_REPO_URL roles
  cd roles
  git checkout $ROLES_REPO_BRANCH
  git fetch
  git pull
  cd ..
  cp ./template/playbook.yml ./
  for i in ${PLAYBOOKS//,/ }
    do
        echo "  - $i.yml" >> ./playbook.yml
    done
  touch ./.prepared
fi

INSTALLED="$(ls /ansible/playbook/.installed)"
if [[ -z "$INSTALLED" ]]; then
  cat ./playbook.yml
#  ansible-playbook -c local -i ./inventory/localhost  playbook.yml
fi

#while (true) do sleep 86400; done
watch -n 86400 /opt/ansible/run_ansible_playbook.sh
#dr_scripts_ref
