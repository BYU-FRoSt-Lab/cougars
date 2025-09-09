#!/bin/bash
#
# ADD HERE

# Replace 'eth0' with your Ethernet connection name
CONNECTION_NAME="eth0"

# Deactivate the connection
sudo nmcli connection down "$CONNECTION_NAME"
echo "Deactivated $CONNECTION_NAME"

# Wait for 5 seconds
sleep 5

# Reactivate the connection
sudo nmcli connection up "$CONNECTION_NAME"

# Check if the connection is successfully activated
if [ $? -eq 0 ]; then
    echo "Successfully reactivated $CONNECTION_NAME"
else
    echo "Failed to reactivate $CONNECTION_NAME"
fi
