# !/bin/bash

source scripts/utils/print.sh
# Check for clean flag
CLEAN=0
if [[ "$1" == "-c" ]]; then
    CLEAN=1
fi

if [ $CLEAN -eq 1 ]; then
    docker exec -it cougars bash -c "rm -rf ~/ros2_ws/build ~/ros2_ws/install ~/ros2_ws/log"
    docker exec -it cougars_base bash -c "rm -rf ~/ros2_ws/build ~/ros2_ws/install ~/ros2_ws/log"
    docker exec -it cougars_sim bash -c "rm -rf ~/sim_ws/build ~/sim_ws/install ~/sim_ws/log"
fi

# check if cougars container is running
if ! [ "$(docker ps -q -f name=cougars)" ]; then
    printError "The cougars container is not running. Please start the container and try again."
else
    # Builds the ros2 ws for the cougars project
    docker exec -it cougars bash -c "source /opt/ros/humble/setup.bash && cd ~/ros2_ws && colcon build"
fi

# check if cougars_base container is running
if ! [ "$(docker ps -q -f name=cougars_base)" ]; then
    printWarning "The cougars_base container is not running. Please start the container and try again."
else
    # Builds the base station ros2 ws for the cougars project
    docker exec -it cougars_base bash -c "source /opt/ros/humble/setup.bash && cd ~/ros2_ws && colcon build"
fi


if ! [ "$(docker ps -q -f name=cougars_sim)" ]; then
    printWarning "The cougars_sim container is not running. Please start the container and try again."
else
    # Builds the simulation workspace for the cougars project
    # Need the true because the first command fails when it can't source the workspace. Could be fixed in the setup.bash file
    docker exec -it cougars_sim bash -c "source ~/sim_ws/setup.bash || true; cd ~/sim_ws && colcon build"
fi