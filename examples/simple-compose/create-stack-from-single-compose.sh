#!/bin/sh
echo "Creating PostgreSQL, SonarQube, Nexus, Jenkins container ..."
docker-compose -f ./stack-docker-compose.yml up -d -t 180 --remove-orphans
