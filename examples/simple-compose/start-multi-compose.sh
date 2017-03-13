#!/bin/sh
cd sonar-db.riglet
echo "Starting PostgreSQL container ..."
docker-compose start
cd ../sonar.riglet
echo "Starting SonarQube containers ..."
docker-compose start
cd ../nexus.riglet
echo "Starting Nexus containers ..."
docker-compose start
cd ../jenkins.riglet
echo "Starting Jenkins containers ..."
docker-compose start
