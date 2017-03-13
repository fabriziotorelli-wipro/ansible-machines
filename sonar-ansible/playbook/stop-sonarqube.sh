#!/bin/bash
if ! [[ -z "$( ps -eaf | grep sonar )" ]]; then
  ps -eaf | grep sonar | awk 'BEGIN {FS=OFS=" "}{print $3}'| xargs kill
fi
