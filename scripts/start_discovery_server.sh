#!/bin/bash

echo "[INFO] Checking for existing fastdds discovery processes..."

# Get PIDs of running processes
PIDS=$(pgrep -f "fastdds.*discovery")
PIDS+=" $(pgrep -f fast-discovery-server)"

# Trim and check if any PIDs found
PIDS=$(echo $PIDS | xargs)  # Remove extra whitespace

if [[ -n "$PIDS" ]]; then
    echo "[INFO] Killing existing discovery server processes: $PIDS"
    kill -9 $PIDS
    sleep 1
else
    echo "[INFO] No existing discovery processes found."
fi

echo "[INFO] Launching fastdds discovery..."
# Run command directly — output will print to terminal
exec fastdds discovery --server-id 0