#!/bin/sh
cd sonar-db.riglet
echo "Destroying PostgreSQL container ..."
docker-compose down -v  --remove-orphans
cd ../sonar.riglet
echo "Destroying SonarQube containers ..."
docker-compose down -v  --remove-orphans
cd ../nexus.riglet
echo "Destroying Nexus containers ..."
docker-compose down -v  --remove-orphans
cd ../jenkins.riglet
echo "Destroying Jenkins containers ..."
docker-compose down -v  --remove-orphans
