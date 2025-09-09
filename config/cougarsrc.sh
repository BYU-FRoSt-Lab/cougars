#!/bin/bash
# cougarsrc bashrc type script that will be sourced in every terminal that is general for every vehicle
#

source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
# TODO: This will only work inside the container but it hopefully only needs to work inside the container
source ~/config/cougrc.sh
source ~/scripts/utils/print.sh

export FASTRTPS_DEFAULT_PROFILES_FILE=~/config/fast_discovery_config.xml
export FLEET_PARAMS_FILE=~/config/deploy_tmp/fleet_params.yaml # ex. ~/config/fleet_params.yaml

