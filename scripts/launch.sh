#!/bin/bash
#

# MODIFIED: This script has been updated to pass arguments to ROS 2 launch files
# using the standard 'argument_name:=value' syntax for better compatibility.
#
# Starts the micro-ROS agent and ROS 2 launch files
# - Specify a launch configuration using 'bash launch.sh <launch>' (ex. 'bash launch.sh moos')
source ~/config/cougarsrc.sh

# cleanup() {
#   echo ""
  
#   if [ "$(uname -m)" == "aarch64" ]; then
#     bash ~/teensy_ws/gpio_tools/strobe.sh off
#     bash ~/ros2_ws/dvl_tools/acoustics_on.sh false
#   fi
  
#   exit 0
# }
# trap cleanup SIGINT

echo ""
echo -e "\033[0m\033[36m######################################################################\033[0m"
echo -e "\033[0m\033[36m#\033[0m BYU FROST LAB - CONFIGURABLE UNDERWATER GROUP OF AUTONOMOUS ROBOTS \033[0m\033[36m#\033[0m"
echo -e "\033[0m\033[36m######################################################################\033[0m"
echo ""

# Parse options
SIM="False" # Default value for sim
DEMO="False" # Default value for demo
VERBOSE="False"
GPS="False"
FINS="False"
# Set a default vehicle parameter file. It can be overridden by the -s flag.

while getopts "svgfdb" opt; do
  case $opt in
    s)
      SIM="True"
      ;;
    d)
      DEMO="True"
      printWarning "Demo mode enabled. Depth Sensor will not publish"
      ;;
    v)
      VERBOSE="True"
      ;;
    *)
      printError "Invalid option"
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1)) # Shift positional arguments

echo ""

if [ "$(uname -m)" == "aarch64" ]; then
  # Quick fix for daemon error (TODO: find a better solution)
  ros2 daemon stop
  ros2 daemon start
  sleep 3
  # Start the strobe light and Teensy board
  bash ~/teensy_ws/gpio_tools/strobe.sh on
  bash ~/teensy_ws/gpio_tools/power.sh on

  # Test for Teensy board connection
  if [ -z "$(tycmd list | grep Teensy)" ]; then
      printError "No Teensy boards avaliable to connect to"
      exit 1
  fi

  echo ""
fi


#TODO demo option that launchs the teensy controller fins even with sim?
#TODO just make a parameter in yaml for moos GPS Only

# Start both workspaces
source ~/ros2_ws/install/setup.bash

case $1 in
    "full")
        ros2 launch cougars_bringup persistant_launch.py \
        namespace:=$NAMESPACE \
        param_file:=$VEHICLE_PARAMS_FILE \
        fleet_param:=$FLEET_PARAMS_FILE \
        sim:=$SIM \
        verbose:=$VERBOSE \
        fins:=$FINS \
        demo:=$DEMO
        ;;
    "manual")
        ros2 launch cougars_control manual_launch.py \
          namespace:="$NAMESPACE" \
          param_file:="$VEHICLE_PARAMS_FILE" \
          sim:="$SIM" \
          verbose:="$VERBOSE" \
          fins:="$FINS" \
          demo:="$DEMO"
        ;;
    "moos")
        ros2 launch cougars_control moos_launch.py \
          namespace:="$NAMESPACE" \
          param_file:="$VEHICLE_PARAMS_FILE" \
          sim:="$SIM" \
          verbose:="$VERBOSE" \
          GPS:="$GPS"
        ;;
    "sensors")
        ros2 launch cougars_localization sensors_launch.py \
          namespace:="$NAMESPACE" \
          param_file:="$VEHICLE_PARAMS_FILE"
        ;;

    "demo")
        ros2 launch cougars_control demo_launch.py \
          namespace:="$NAMESPACE" \
          param_file:="$VEHICLE_PARAMS_FILE"
        ;;
    "waypoint")
        # Launch with the selected mission file
        ros2 launch cougars_control waypoint_launch.py \
        namespace:=$NAMESPACE \
        param_file:=$VEHICLE_PARAMS_FILE \
        sim:=$SIM \
        verbose:=$VERBOSE \
        mission_file:=$MISSION_NAME \
        GPS:=$GPS
        ;;

    "bluerov")
        ros2 launch cougars_control bluerov_launch.py \
          namespace:="$NAMESPACE" \
          param_file:="$VEHICLE_PARAMS_FILE" \
          BLUEROV:="true" \
          verbose:="$VERBOSE"
        ;;

    *)
        printError "No start configuration specified"
        printError "Specify a launch configuration using 'bash launch.sh <config>' (ex. 'bash launch.sh moos')"
        ;;
esac

cleanup