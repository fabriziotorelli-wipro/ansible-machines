#!/bin/bash
CONTAINERS="$(docker ps -a| grep -v NAME)"
if ! [[ -z "$CONTAINERS" ]]; then
    docker ps -a | grep -v NAME | awk 'BEGIN {FS=OFS=" "}{print $1}'|xargs docker rm -f
fi
IMAGES="$(docker images -a | grep -v IMAGE)"
if ! [[ -z "$IMAGES" ]]; then
    docker images -a | grep -v IMAGE | awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
fi
VOLUMES="$(docker volume ls | grep -v VOLUME)"
if ! [[ -z "$VOLUMES" ]]; then
    docker volume ls|grep -v VOLUME|awk 'BEGIN {FS=OFS=" "}{print $2}' | xargs docker volume rm -f
fi
