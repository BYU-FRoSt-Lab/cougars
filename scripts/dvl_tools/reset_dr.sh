#!/bin/bash
#

source ~/ros2_ws/dvl_tools/send_command.sh

# Main execution
MAX_ATTEMPTS=3
TIMEOUT=3

# Reset Dead Reckoning
execute_with_retry "\"reset_dead_reckoning\"" "Reset Dead Reckoning" $TIMEOUT || exit 1