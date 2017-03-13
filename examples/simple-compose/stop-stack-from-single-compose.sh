#!/bin/sh
echo "Stop PostgreSQL, SonarQube, Nexus, Jenkins containers ..."
docker-compose -f ./stack-docker-compose.yml start -t 120
