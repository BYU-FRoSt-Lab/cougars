# !/bin/bash

# unset the env variable used for fast discovery
unset FASTRTPS_DEFAULT_PROFILES_FILE

ros2 daemon stop
sleep 1
ros2 daemon start