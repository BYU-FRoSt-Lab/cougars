#!/bin/bash
#
# ADD HERE

source ~/config/bash_vars.sh
curl -X POST -d "{\"ntp_enabled\":true,\"ntp_server\":\"$STATIC_IP\",\"ntp_synchronized\":true}" -H "Content-Type: application/json" http://192.168.194.95/api/v1/time/ntp
