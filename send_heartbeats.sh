#!/bin/bash

IDLE_LIMIT=600 

last_time=$(date +%s)

xev -root | grep --line-buffered "KeyPress" | while read line; do
    activity=$(date +%s)
    echo "Key pressed at $(date)"
done &

xev_pid=$!
