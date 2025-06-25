#!/bin/bash
# Created by Nelson Durrant, Sep 2024
#
# Starts or enters the tmux session
# - Use 'bash tmux.sh kill' to kill the session

source config/cougarsrc.sh

case $1 in
  "kill")
    printWarning "Killing the tmux session..."
    tmux kill-session -t cougars
    ;;
  *)
    # Check if the tmux session is already running
    if [ -z "$(tmux list-sessions | grep cougars)" ]; then

      printInfo "Starting the tmux session..."

      ### FIRST WINDOW - ROS SCRIPTS ###

      # Start the tmux session
      tmux new-session -d -s cougars -n "coug"
      tmux split-window -h -t cougars
      tmux split-window -v -t cougars
      tmux select-pane -t cougars:coug.0
      tmux split-window -v -t cougars
      tmux select-pane -t cougars:coug.0

      # Send commands to the tmux session
      tmux send-keys -t cougars:coug.0 "echo 'frostlab' | sudo -S systemctl restart chrony" ENTER

      tmux send-keys -t cougars:coug.0 "bash compose.sh" ENTER
      tmux send-keys -t cougars:coug.0 "clear" ENTER
      tmux send-keys -t cougars:coug.1 "bash compose.sh" ENTER
      tmux send-keys -t cougars:coug.1 "clear" ENTER
      tmux send-keys -t cougars:coug.2 "bash compose.sh" ENTER
      tmux send-keys -t cougars:coug.2 "clear" ENTER
      tmux send-keys -t cougars:coug.3 "bash compose.sh" ENTER
      tmux send-keys -t cougars:coug.3 "clear" ENTER

      tmux send-keys -t cougars:coug.0 "cd ~/ros2_ws" ENTER
      tmux send-keys -t cougars:coug.0 "bash launch.sh <mission_type>" # Don't start just yet

      tmux send-keys -t cougars:coug.1 "cd ~/ros2_ws" ENTER
      tmux send-keys -t cougars:coug.1 "bash test.sh <acoustics>" # Don't start just yet

      tmux send-keys -t cougars:coug.2 "cd ~/ros2_ws" ENTER
      tmux send-keys -t cougars:coug.2 "bash record.sh <acoustics>" # Don't start just yet

      tmux send-keys -t cougars:coug.3 "cd ~/config" ENTER
      tmux send-keys -t cougars:coug.3 "cat $VEHICLE_PARAMS_FILE" ENTER

      ### SECOND WINDOW - MOOS SCRIPTS ###

      tmux new-window -t cougars -n "moos"
      tmux split-window -h -t cougars:moos
      tmux select-pane -t cougars:moos.0
      tmux split-window -v -t cougars:moos.0

      tmux send-keys -t cougars:moos.0 "bash compose.sh" ENTER
      tmux send-keys -t cougars:moos.0 "clear" ENTER
      tmux send-keys -t cougars:moos.1 "bash compose.sh" ENTER
      tmux send-keys -t cougars:moos.1 "clear" ENTER
      tmux send-keys -t cougars:moos.2 "bash compose.sh" ENTER
      tmux send-keys -t cougars:moos.2 "clear" ENTER

      tmux send-keys -t cougars:moos.0 "date" ENTER

      tmux send-keys -t cougars:moos.1 "cat ~/ros2_ws/moos_tools/coug.bhv" ENTER
      tmux send-keys -t cougars:moos.1 "bash ~/ros2_ws/moos_tools/mission_deploy.sh" # Don't start just yet
      

      tmux send-keys -t cougars:moos.2 "cd ~/ros2_ws/moos_tools" ENTER
      tmux send-keys -t cougars:moos.2 "timeout 120s pAntler coug.moos" # Don't start just yet


    else
      printInfo "Attaching to the tmux session..."
    fi

    # Attach to the tmux session
    tmux attach-session -t cougars
    ;;
esac

#TODO: - do we need to add init scripts at all?
#      - can we implement plot juggler?