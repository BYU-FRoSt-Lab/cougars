#!/bin/bash
#
# ADD HERE

source ~/config/cougarsrc.sh

echo -n '{"command": "get_config"}' | nc -q 0 $DVL_IP_ADDRESS 16171

