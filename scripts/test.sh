#!/bin/bash
#
# Tests vehicle sensors and actuators
# - Specify a DVL acoustics power state using 'bash test.sh <state>' (ex. 'bash test.sh off')
# - Run this after running the 'launch.sh' script
source ~/config/cougarsrc.sh

if [ "$(uname -m)" == "aarch64" ]; then
  case $1 in
    "on")
      bash ~/ros2_ws/dvl_tools/acoustics_on.sh true
      ;;
    "off")
      bash ~/ros2_ws/dvl_tools/acoustics_on.sh false
      ;;
    *)
      printError "No state specified for DVL acoustics"
      printError "Specify a state using either 'bash test.sh on' or 'bash test.sh off'"
      exit 1
      ;;
  esac
fi

echo ""

case $2 in
  "calibrate")
    printInfo "Calibrating"
    bash ~/ros2_ws/calibrate.sh
    ;;
  *)
    printInfo "Will not calibrate"
  
    ;;
esac

echo ""

# TODO: Test this implementation with a string
leak_data=$(timeout 5 ros2 topic echo --once --no-arr $NAMESPACE/leak/data 2>/dev/null | grep -oP '(?<=fluid_pressure: )\d+(\.\d+)?')
if [ -z "$leak_data" ]; then
  printFailure "No leak sensor connection found."
else
  if awk "BEGIN {exit !($leak_data == 0.0)}"; then
    printSuccess "Leak sensor connected!"
    echo "  leak: $leak_data"
  else
    printFailure "Leak sensor may not be working."
    echo "  leak: $leak_data"
  fi
fi

battery_data=$(timeout 5 ros2 topic echo --once --no-arr $NAMESPACE/battery/data 2>/dev/null | grep -oP '(?<=voltage: )\d+(\.\d+)?')
if [ -z "$battery_data" ]; then
  printFailure "No battery monitor connection found."
else
  if [[ $(echo "$battery_data" | awk '{if ($1 == 0.0) print 1; else print 0}') -eq 0 ]]; then
    printSuccess "Battery monitor connected!"
    echo "  voltage: $battery_data"
  else
    printFailure "Battery monitor may not be working."
    echo "  voltage: $battery_data"
  fi
fi

pressure_data=$(timeout 5 ros2 topic echo --once --no-arr $NAMESPACE/pressure/data 2>/dev/null | grep -oP '(?<=fluid_pressure: )\d+(\.\d+)?')
if [ -z "$pressure_data" ]; then
  printFailure "No pressure sensor connection found."
else
  if [[ $(echo "$pressure_data" | awk '{if ($1 == 0.0) print 1; else print 0}') -eq 0 ]]; then
    printSuccess "Pressure sensor connected!"
    echo "  fluid_pressure: $pressure_data"
  else
    printFailure "Pressure sensor may not be working."
    echo "  fluid_pressure: $pressure_data"
  fi
fi

# TODO: This is broken
modem_data=$(timeout 5 ros2 topic echo --once --no-arr $NAMESPACE/modem_status 2>/dev/null | grep -oP '(?<=attitude_yaw: \[)\d+(\.\d+)?')
if [ -z "$modem_data" ]; then
  printFailure "No USBL modem connection found."
else
  if [[ $(echo "$modem_data" | awk '{if ($1 == 0.0) print 1; else print 0}') -eq 0 ]]; then
    printSuccess "USBL modem connected!"
    echo "attitude_yaw: $modem_data"
  else
    printFailure "USBL modem may not be working."
    echo "attitude_yaw: $modem_data"
  fi
fi

gps_data=$(timeout 5 ros2 topic echo --once --no-arr $NAMESPACE/extended_fix 2>/dev/null | grep -oP '(?<=latitude: )\d+(\.\d+)?')
if [ -z "$gps_data" ]; then
  printFailure "No GPS connection found."
else
  if [[ $(echo "$gps_data" | awk '{if ($1 == 0.0) print 1; else print 0}') -eq 0 ]]; then
    printSuccess "GPS connected!"
    echo "  latitude: $gps_data"
  else
    printFailure "GPS may not be working."
    echo "  latitude: $gps_data"
  fi
fi

dvl_data=$(timeout 5 ros2 topic echo --once --no-arr $NAMESPACE/dvl/data 2>/dev/null | grep -oP '(?<=altitude: \[)\d+(\.\d+)?')
if [ -z "$dvl_data" ]; then
  printFailure "No DVL connection (data) found."
else
  if [[ $(echo "$dvl_data" | awk '{if ($1 == 0.0) print 1; else print 0}') -eq 0 ]]; then
    printSuccess "DVL (data) connected!"
    echo "  altitude: $dvl_data"
  else
    printFailure "DVL (data) may not be working."
    echo "  altitude: $dvl_data"
  fi
fi

# TODO: This is broken
dvl_position_data=$(timeout 5 ros2 topic echo --once --no-arr $NAMESPACE/dvl/position 2>/dev/null | grep -A 3 position: | grep -oP '(?<=x: )\d+(\.\d+)?')
if [ -z "$dvl_position_data" ]; then
  printFailure "No DVL connection (position) found."
else
  if [[ $(echo "$dvl_position_data" | awk '{if ($1 == 0.0) print 1; else print 0}') -eq 0 ]]; then
    printSuccess "DVL (position) connected!"
    echo "  x: $dvl_position_data"
  else
    printFailure "DVL (position) may not be working."
    echo "  x: $dvl_position_data"
  fi
fi

echo ""

printInfo "Testing top servo, publishing to 'kinematics/command'..."
timeout 5 ros2 topic pub -1 $NAMESPACE/kinematics/command frost_interfaces/msg/UCommand '{fin: [45, 0, 0, 0], thruster: 0}' 2>/dev/null

printInfo "Testing side servos, publishing to 'kinematics/command'..."
timeout 5 ros2 topic pub -1 $NAMESPACE/kinematics/command frost_interfaces/msg/UCommand '{fin: [0, 45, 45, 0], thruster: 0}' 2>/dev/null

printInfo "Testing thruster (ON), publishing to 'kinematics/command'..."
timeout 5 ros2 topic pub -1 $NAMESPACE/kinematics/command frost_interfaces/msg/UCommand '{fin: [0, 0, 0, 0], thruster: 10}' 2>/dev/null

printInfo "Testing thruster (OFF), publishing to 'kinematics/command'..."
timeout 5 ros2 topic pub -1 $NAMESPACE/kinematics/command frost_interfaces/msg/UCommand '{fin: [0, 0, 0, 0], thruster: 0}' 2>/dev/null
