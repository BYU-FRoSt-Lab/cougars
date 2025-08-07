#!/bin/bash
# - Make sure you run this from the root of the top-level repo


# Check for force flag
FORCE=0
if [[ "$1" == "-f" ]]; then
    FORCE=1
fi

# Set up workspace
# To be run from the root of the top-level repo
if [ $FORCE -eq 1 ]; then
    echo "Force flag set: cleaning ros2_ws and other directories"
    rm -rf ros2_ws/src
    rm -rf cougars-teensy cougars-gpio cougars-base-station cougars-docs
    mkdir -p ros2_ws/src

    vcs import < .vcs/runtime.repos

    mkdir -p ros2_ws/src
    vcs import < .vcs/cougars.ros2.repos ros2_ws/src
    cd ros2_ws/src/dvl-a50 
    git submodule update --init --recursive
    cd ../../..

    # Set up vcs and clone repos
    vcs import < .vcs/dev.repos
fi



# Docker updates
docker pull frostlab/cougars:vehicle
docker pull frostlab/cougars:base_station

vcs pull ros2_ws/src

vcs pull cougars-teensy cougars-gpio cougars-base-station cougars-docs



