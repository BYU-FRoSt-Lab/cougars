#!/bin/bash
# cougarsrc bashrc type script that will be sourced in every terminal that is general for every vehicle
#

source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
export FASTRTPS_DEFAULT_PROFILES_FILE=~/config/fast_discovery_config.xml
export FLEET_PARAMS_FILE=~/config/deploy_tmp/fleet_params.yaml # ex. ~/config/fleet_params.yaml

# TODO: This will only work inside the container but it hopefully only needs to work inside the container
source ~/config/cougrc.sh


function printInfo {
  echo -e "\033[0m\033[36m[INFO] $1\033[0m"
}

function printWarning {
  echo -e "\033[0m\033[33m[WARNING] $1\033[0m"
}

function printError {
  echo -e "\033[0m\033[31m[ERROR] $1\033[0m"
}

function printSuccess {
  echo -e "\033[0m\033[32m[SUCCESS] $1\033[0m"
}

function printFailure {
  echo -e "\033[0m\033[31m[FAIL] $1\033[0m"
}



