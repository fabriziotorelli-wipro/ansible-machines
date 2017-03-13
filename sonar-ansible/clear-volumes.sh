#!/bin/sh
docker volume ls|grep -v VOLUME|awk 'BEGIN {FS=OFS=" "}{print $2}' | xargs docker volume rm -f
