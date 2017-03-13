#!/bin/sh
echo "Destroying PostgreSQL, SonarQube, Nexus, Jenkins containers ..."
docker-compose -f ./stack-docker-compose.yml down -v  --remove-orphans
