#!/bin/bash
set -e

COMMANDS="debug help logtail show stop adduser fg kill quit run wait console foreground logreopen reload shell status"
START="start restart"

if [ ! -z "$CRONTAB" ]; then
  sed -i -e "s/LINKCHECKER_USER/$LINKCHECKER_USER/g" crontab.cfg
  sed -i -e "s/LINKCHECKER_PASSWORD/$LINKCHECKER_PASSWORD/g" crontab.cfg
  crontab -u zope crontab.cfg
  crond
fi

if [[ $START == *"$1"* ]]; then
  _stop() {
    bin/instance stop
    kill -TERM $child 2>/dev/null
  }

  /usr/sbin/crond
  trap _stop SIGTERM SIGINT

  if [ ! -z "$DEBUG_MODE" ]; then
    bin/develop up
  fi

  bin/instance start
  bin/instance logtail &

  child=$!
  wait "$child"
else
  if [[ $COMMANDS == *"$1"* ]]; then
    exec bin/instance "$@"
  fi
  exec "$@"
fi
