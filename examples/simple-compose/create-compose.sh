#!/bin/sh
echo "Creating PostgreSQL for SonarQube container ..."
cd sonar-db.riglet
docker-compose up -d -t 120 --remove-orphans
echo "Waiting grace time between compose start-up ..."
sleep 45
cd ../sonar.riglet
echo "Creating SonarQube containers ..."
docker-compose up -d -t 120 --remove-orphans
echo "Waiting grace time between compose start-up ..."
cd ../nexus.riglet
sleep 45
echo "Creating Nexus containers ..."
docker-compose up -d -t 120 --remove-orphans
echo "Waiting grace time between compose start-up ..."
cd ../jenkins.riglet
sleep 45
echo "Creating Jenkins containers ..."
docker-compose up -d -t 120 --remove-orphans
