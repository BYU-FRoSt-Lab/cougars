#!/bin/bash
# - Make sure you run this from the root of the top-level repo

source scripts/utils/print.sh

# Check for force flag
FORCE=0
if [[ "$1" == "-f" ]]; then
    FORCE=1
    shift
fi          

# Determine clone method from argument or default to SSH
if [[ "$1" == "-h" ]]; then
    VCS_FILE_SUFFIX="_https"
else
    VCS_FILE_SUFFIX=""
fi

# Set up workspace
if [ $FORCE -eq 1 ]; then

    echo "Cleaning ros2_ws and other directories"
    rm -rf ros2_ws/src
    rm -rf teensy_ws base_station

    vcs import < .vcs/runtime$VCS_FILE_SUFFIX.repos

    mkdir -p ros2_ws/src
    vcs import < .vcs/cougars_ros2$VCS_FILE_SUFFIX.repos ros2_ws/src
    cd ros2_ws/src/dvl-a50 
    git submodule update --init --recursive
    cd ../../..

    # TODO ask if they want to do this
    # TODO add the prompt to ask if the user wants to do this
    sudo chmod a+w -R ros2_ws teensy_ws

    if [ "$(uname -m)" != "aarch64" ]; then
        printInfo "Including base station repository for non-ARM architecture"
        vcs import < .vcs/dev$VCS_FILE_SUFFIX.repos
        sudo chmod a+w -R base_station
    fi
else

    vcs pull teensy_ws 
    vcs pull ros2_ws/src

    # If device is not ARM, pull base station too
    if [ "$(uname -m)" != "aarch64" ]; then
        vcs pull base_station
    fi
fi


# Docker updates
docker pull frostlab/cougars:vehicle
if [ "$(uname -m)" == "aarch64" ]; then
    printInfo "Will not pull base station image on ARM architecture"
else
    printInfo "Pulling base station image"
    docker pull frostlab/cougars:base_station
fi


