#!/bin/bash

# Check if the correct number of arguments is provided
source ~/ros2_ws/dvl_tools/send_command.sh

if [ "$#" -ne 1 ]; then
  printError "Usage: $0 <true|false>"
  exit 1
fi

# Assign the first argument to the variable
ACOUSTIC_ENABLED=$1

# Validate the input to ensure it's either "true" or "false"
if [[ "$ACOUSTIC_ENABLED" != "true" && "$ACOUSTIC_ENABLED" != "false" ]]; then
  printError "DVL acoustics argument must be 'true' or 'false'."
  exit 1
fi

# Build the JSON string
JSON_STRING='"set_config","parameters":{"acoustic_enabled":'"$ACOUSTIC_ENABLED"'}'

MAX_ATTEMPTS=2
TIMEOUT=4

# Main execution
execute_with_retry $JSON_STRING "Set acoustics" $TIMEOUT || exit 1