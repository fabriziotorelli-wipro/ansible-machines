#!/bin/sh
cd sonar-db.riglet
echo "Stopping PostgreSQL container ..."
docker-compose stop -t 30
cd ../sonar.riglet
echo "Stopping SonarQube containers ..."
docker-compose stop -t 30
cd ../nexus.riglet
echo "Stopping Nexus containers ..."
docker-compose stop -t 30
cd ../jenkins.riglet
echo "Stopping Jenkins containers ..."
docker-compose stop -t 30
