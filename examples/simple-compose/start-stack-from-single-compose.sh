#!/bin/sh
echo "Starting PostgreSQL, SonarQube, Nexus, Jenkins containers ..."
docker-compose -f ./stack-docker-compose.yml start
