#!/bin/bash
if ! [[ -z "$(docker ps -a| grep jenkins-ansible)" ]]; then
   if ! [[ -z "$(docker ps| grep jenkins-ansible)" ]]; then
      docker stop jenkins-ansible
   fi
   docker commit -a "Fabrizio Torelli <fabrizio.torelli@wipro.com>" -m "Microservices Pipeline - Ansible Jenkins" -c "ENV PLAYBOOKS=microservices-recreate" -c "CMD rm -f /usr/local/share/ansible/playbook/.installed && /usr/local/share/ansible/playbook/run_ansible_playbook.sh"  jenkins-ansible builditftorelli/jenkins-microservices:2.32.3
   echo "Starting a test container ..."
   docker run -d --name jenkins-microservices -p 8080:8080 -p 50000:50000 -it builditftorelli/jenkins-microservices:2.32.3
   docker logs -f jenkins-microservices
else
   echo "No image found. Please run test.sh before. Create the default microservices image and then you can pack-it in an image!!"
fi
