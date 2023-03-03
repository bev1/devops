#!/bin/bash

# default threshold(bytes)
threshold=$((1024 * 1024 * 1024)) # 1GB

# threshold from argument
if [[ $# -gt 0 ]]; then
    threshold=$1
fi

echo threshold = $threshold

# check free disk space function
check_disk_space() {
    df -B1 --output=avail / | tail -n 1
}

while true; do
    free_space=$(check_disk_space)
    echo free_space = $free_space

    if [[ $free_space -lt $threshold ]]; then
        echo "Warning: free disk space is below threshold"
    fi

    sleep 5
done