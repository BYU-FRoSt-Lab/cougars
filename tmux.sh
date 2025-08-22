#!/bin/bash
# Enhanced tmux session script with flexible windows and SSH option

source config/cougarsrc.sh

SESSION="cougars"
ADD_BASE=false
ADD_SIM=false
SSH_IP=""

# Parse arguments
while getopts ":absi:" opt; do
  case $opt in
    a)
      ADD_BASE=true
      ADD_SIM=true
      ;;
    b)
      ADD_BASE=true
      ;;
    s)
      ADD_SIM=true
      ;;
    i)
      SSH_IP="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-a] [-b] [-s] [-i ip_address] | kill"
      exit 1
      ;;
  esac
done

# Shift out processed flags
shift $((OPTIND -1))

# Handle kill case
if [ "$1" == "kill" ]; then
  printWarning "Killing the tmux session..."
  tmux kill-session -t $SESSION
  exit 0
fi

# Start session only if not already running
if ! tmux has-session -t $SESSION 2>/dev/null; then
  printInfo "Creating tmux session: $SESSION"

  #### WINDOW 1 - coug (default window) ####
  tmux new-session -d -s $SESSION -n "coug"
  tmux split-window -h -t $SESSION:coug.0
  tmux select-pane -t $SESSION:coug.0

  tmux send-keys -t $SESSION:coug.0 "docker exec -it cougars bash" C-m
  tmux send-keys -t $SESSION:coug.1 "docker exec -it cougars bash" C-m

  tmux send-keys -t $SESSION:coug.0 "clear" C-m
  tmux send-keys -t $SESSION:coug.0 "bash scripts/launch.sh <mission_type>"

  tmux send-keys -t $SESSION:coug.1 "clear" C-m
  tmux send-keys -t $SESSION:coug.1 "bash scripts/test.sh <acoustics>"

  #### Optional: WINDOW 2 - base ####
  if [ "$ADD_BASE" = true ]; then
    tmux new-window -t $SESSION -n "base"
    tmux split-window -v -t $SESSION:base
    tmux split-window -h -t $SESSION:base.1
    tmux send-keys -t $SESSION:base.0 "docker exec -it cougars_base bash" C-m
    tmux send-keys -t $SESSION:base.0 "cd base_station/base-station-ros2 && source install/setup.bash" C-m
    tmux send-keys -t $SESSION:base.1 "docker exec -it cougars_base bash" C-m
    tmux send-keys -t $SESSION:base.2 "docker exec -it cougars_base bash" C-m

    tmux send-keys -t $SESSION:base.0 "clear" C-m
    tmux send-keys -t $SESSION:base.1 "clear" C-m
    tmux send-keys -t $SESSION:base.2 "clear" C-m

    tmux send-keys -t $SESSION:base.0 "ros2 launch launch/terminal_launch.py"
    tmux send-keys -t $SESSION:base.1 "ros2 run plotjuggler plotjuggler"
    tmux send-keys -t $SESSION:base.2 "cd ~/base_station/mission_control && bash sync_bags.sh"
  fi

  #### Optional: WINDOW 3 - sim ####
  if [ "$ADD_SIM" = true ]; then
    tmux new-window -t $SESSION -n "sim"
    # SSH into IP address in a new pane if provided
    if [ -n "$SSH_IP" ]; then
      tmux send-keys -t $SESSION:sim.0 "ssh -Y ue4@$SSH_IP -p 2233" C-m
      # Fast Discovery Server
      tmux split-window -h -t $SESSION:sim
      tmux send-keys -t $SESSION:sim.1 "ssh ue4@$SSH_IP -p 2233" C-m
      tmux send-keys -t $SESSION:sim.1 "fastdds discovery --server-id 0" C-m
    else
      tmux send-keys -t $SESSION:sim.0 "docker exec -it cougars-sim-holoros bash" C-m
    fi
    tmux send-keys -t $SESSION:sim.0 "cd ~/sim_ws && source setup.bash" C-m
    tmux send-keys -t $SESSION:sim.0 "clear" C-m
    tmux send-keys -t $SESSION:sim.0 "ros2 launch sim_converters full_launch.py params_file:=/home/ue4/sim_config/ros_params.yaml"


  fi
else
  printInfo "Attaching to existing tmux session: $SESSION"
fi

# Attach to the session
tmux attach -t $SESSION
