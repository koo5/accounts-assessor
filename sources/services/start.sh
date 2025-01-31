#!/usr/bin/env bash
set -xv
../wait-for-it/wait-for-it.sh $RABBITMQ_URL -t 0

_term() {
  echo "Caught SIGTERM signal!"
  kill -TERM "$child" 2>/dev/null
}
trap _term SIGTERM

if $WATCHMEDO; then
  watchmedo auto-restart --debounce-interval 1 --interval $WATCHMEDO_INTERVAL -d .  -d  ../common  --patterns="*.py;*.egg" --recursive -- ./start2.sh &
else
  ./start2.sh &
fi

child=$!
wait "$child"
echo "end"

