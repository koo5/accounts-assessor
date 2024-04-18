#!/usr/bin/env bash

if [ ! -z $WATCHMEDO ]; then
	watchmedo auto-restart --debounce-interval 1 --interval $WATCHMEDO_INTERVAL -d src --recursive  -- ./src/start2.sh
else
  ./src/start2.sh
fi
