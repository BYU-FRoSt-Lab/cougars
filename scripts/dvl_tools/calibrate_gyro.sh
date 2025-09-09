#!/bin/bash
#

source ~/ros2_ws/dvl_tools/send_command.sh

MAX_ATTEMPTS=3
TIMEOUT=15

# Calibrate Gyro
execute_with_retry "\"calibrate_gyro\"" "Calibrate Gyro" $TIMEOUT || exit 1

#echo -n '{"command": "calibrate_gyro"}' | nc -q 0 192.168.194.95 16171