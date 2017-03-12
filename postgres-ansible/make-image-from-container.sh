#!/bin/bash
if ! [[ -z "$(docker ps -a| grep postgres-ansible)" ]]; then
   if ! [[ -z "$(docker ps| grep postgres-ansible)" ]]; then
      docker stop postgres-ansible
   fi
   docker commit -a "Fabrizio Torelli <fabrizio.torelli@wipro.com>" -m "Microservices Pipeline - Ansible Jenkins" -c "ENV PLAYBOOKS=microservices,microservices-recreate" -c "CMD rm -f /usr/local/share/ansible/playbook/.prepared && rm -Rf /usr/local/share/ansible/playbook/main && rm -Rf /usr/local/share/ansible/playbook/roles  && rm -f /usr/local/share/ansible/playbook/.installed && /usr/local/share/ansible/playbook/run_ansible_playbook.sh"  postgres-ansible builditftorelli/postgres-microservices:9.6
   echo "Starting a test container ..."
   docker run -d --name postgres-microservices -p 8080:8080 -p 50000:50000 -it builditftorelli/postgres-microservices:9.6
   docker logs -f postgres-microservices
else
   echo "No image found. Please run test.sh before. Create the default microservices image and then you can pack-it in an image!!"
fi
