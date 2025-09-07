#!/bin/bash

USERNAME=""

VM_NAME="$(cat /etc/hostname)"
API_URL="https://api.vmpheus.eryxks.dev/api/v1/heartbeat"
HEARTBEAT_INTERVAL=120
ACTIVE_TIMEOUT=600

cores=$(nproc)
samples=5 
interval=0.5
last_keypress=$(date +%s)

get_cpu_usage() {
    cpu_total=0

    for i in $(seq 1 $samples); do
        usage=$(ps -u "$USERNAME" -o pcpu= | awk '{sum += $1} END {print sum}')
        cpu_total=$(awk -v total="$cpu_total" -v usage="$usage" 'BEGIN {print total + usage}')
        sleep $interval
    done

    cpu_avg=$(awk -v total="$cpu_total" -v samples="$samples" -v cores="$cores" 'BEGIN {printf "%.2f", total / samples / cores}')
    echo "$cpu_avg"
}

get_ram_usage() {
    mem_usage=$(ps -u "$USERNAME" -o pmem= | awk '{sum += $1} END {print sum}')
    echo "$mem_usage"
}

send_heartbeat() {
    local cpu_usage=$1
    local ram_usage=$2
    
    local current_time=$(date +%s)
    local time_since_last_keypress=$((current_time - last_keypress))
    local active="false"
    
    [ $time_since_last_keypress -le $ACTIVE_TIMEOUT ] && active="true"

    curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"vm_name\": \"$VM_NAME\",
            \"user\": \"$USERNAME\",
            \"active\": $active,
            \"cpu\": $cpu_usage,
            \"ram\": $ram_usage
        }" > /dev/null 2>&1
}

xev -root 2>/dev/null | grep --line-buffered "KeyPress" | while read line; do
    last_keypress=$(date +%s)
done & 

while true; do
    cpu_usage=$(get_cpu_usage)
    ram_usage=$(get_ram_usage)
    send_heartbeat "$cpu_usage" "$ram_usage"
    sleep $HEARTBEAT_INTERVAL
done
