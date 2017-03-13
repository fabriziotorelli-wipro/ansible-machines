#!/bin/bash
if [[ -z "$( ps -eaf | grep sonar )" ]]; then
  echo "off"
else
  echo "on"
fi
