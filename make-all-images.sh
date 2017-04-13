#!/bin/bash
docker images | grep builditftorelli | awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
cd jenkins-ansible
./build.sh
cd ../nexus-ansible
./build.sh
cd ../postgres-ansible
./build.sh
cd ../sonar-ansible
./build.sh
docker images | grep builditftorelli | awk 'BEGIN {FS=OFS=" "}{print "docker push "$1":"$2";"}'| sh
