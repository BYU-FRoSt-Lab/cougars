#!/bin/bash
#
# Sets up environment requirements on a new RPi 5
# - Run this script on a newly flashed Raspberry Pi 5. After running it, run 'compose.sh' to load in and run the most current image
# - This script can also be used to set up a new development environment on a personal machine
# - Make sure you run this from the root of the top-level repo

source config/cougarsrc.sh

echo "This script should be run from the root of the CoUGARS directory"

# TODO check if coug is already an alias
if grep -q "alias coug" ~/.bashrc; then
    printWarning "The alias 'coug' already exists in your .bashrc file"
else
    # Add alias to .bashrc if it doesn't exist
    printInfo "Setting 'coug' as an alias to enter the CoUGARs docker container"
    echo "alias coug='docker exec -it cougars bash'" >> ~/.bashrc
fi

# Check if the NAMESPACE variable is set
if [ -z "$NAMESPACE" ]; then
    # TODO have the user choose a vehicle name (e.g., coug, coug-rt, etc.)
    read -p "Enter a name for your vehicle (e.g., coug, bluerov, etc.): " vehicle_name
    echo "You have chosen '$vehicle_name' as your vehicle name."
    read -p "Choose a number for your vehicle (e.g., 1, 2, etc.): " vehicle_number
    echo "You have chosen '$vehicle_number' as your vehicle number."

    NAMESPACE="${vehicle_name}${vehicle_number}"
    printInfo "Using new vehicle namespace: $NAMESPACE"

else
    vehicle_name="$NAMESPACE"
    printInfo "Using existing vehicle namespace: $vehicle_name"
fi

# # Ask user for clone method choice: HTTPS or SSH
# echo "Choose cloning method for repositories:"
# echo "1) SSH"
# echo "2) HTTPS"
# read -p "Enter the number of your choice [1 or 2]: " clone_method

# if [ "$clone_method" -eq 1 ]; then
#     CLONE_PREFIX="git@github.com:BYU-FRoSt-Lab"
#     printInfo "Cloning using SSH"
# elif [ "$clone_method" -eq 2 ]; then
#     CLONE_PREFIX="https://github.com/BYU-FRoSt-Lab"
#     printInfo "Cloning using HTTPS"
# else
#     printError "Invalid choice. Defaulting to SSH."
#     CLONE_PREFIX="git@github.com:BYU-FRoSt-Lab"
# fi


# Install common dependencies
printInfo "Do you want to install vim, tmux, git, and mosh"
read -p "Install common dependencies? (y/n): " install_deps
if [[ "$install_deps" == "y" || "$install_deps" == "Y" ]]; then
    printInfo "Installing common dependencies: vim, tmux, git, and mosh"
    sudo apt install vim tmux git mosh
else
    printWarning "Skipping installation of common dependencies"
fi

# Set up bag directory
if [ -d "bag" ]; then
    printWarning "The bag directory already exists"
else
    mkdir bag
fi


if [ "$(uname -m)" == "aarch64" ]; then

  ### START RT-SPECIFIC SETUP ###

  printInfo "Setting up CoUGARs on a Raspberry Pi 5"

  # Update and upgrade the system
  sudo apt update
  sudo apt upgrade -y
            
  # Install Docker if not already installed
  if ! [ -x "$(command -v docker)" ]; then
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh
      rm get-docker.sh
      sudo usermod -aG docker $USERNAME
      newgrp docker
  else
      printWarning "Docker is already installed"
  fi

  # Install dependencies
  sudo apt install -y chrony 
  ### END RT-SPECIFIC SETUP ###

  # Set up chrony config file
  if [ -f /etc/chrony/chrony.conf ]; then
      printWarning "The chrony config symlink already exists"
  else
      sudo ln -s $HOME/cougars/config/local/chrony.conf /etc/chrony/chrony.conf
  fi

    # TODO copy these instead of symlinking
  # Set up udev rules
  if [ -f /etc/udev/rules.d/00-teensy.rules ]; then
      printWarning "The udev rules symlink already exists"
  else
      sudo ln -s $HOME/cougars/config/local/00-teensy.rules /etc/udev/rules.d/00-teensy.rules
      sudo ln -s $HOME/cougars/config/local/99-teensy.rules /etc/udev/rules.d/99-teensy.rules
      sudo ln -s $HOME/cougars/config/local/99-seatrac.rules /etc/udev/rules.d/99-seatrac.rules
      sudo udevadm control --reload-rules
      sudo udevadm trigger
  fi
else 
    ### START DEV-SPECIFIC SETUP ###

    # Set up vcs and clone repos
    vcs import < .vcs/dev.repos

    sudo chmod a+w -R cougars-base-station
    sudo chmod a+w -R .ssh_keys 

    ### END DEV-SPECIFIC SETUP ###

fi


# Ask if you want to copy the tmux config file
read -p "Do you want to copy the tmux config file? (y/n): " copy_tmux_config
if [[ "$copy_tmux_config" == "y" || "$copy_tmux_config" == "Y" ]]; then
    cp template/.tmux.conf ~/.tmux.conf
    printInfo "Copied the tmux config file to ~/.tmux.conf"
    tmux source-file ~/.tmux.conf

fi
# Get rid of utf8 error
unset LC_ALL


vcs import < .vcs/runtime.repos

mkdir -p ros2_ws/src
vcs import < .vcs/ros2.repos ros2_ws/src
cd ros2_ws/src/dvl-a50 
git submodule update --init --recursive
cd ../../..

printInfo "Make sure to update the vehicle-specific configuration files in "config" now"

# TODO add the prompt to ask if the user wants to do this
sudo chmod a+w -R cougars-ros2 cougars-teensy cougars-gpio

# Pull the latest Docker images
printInfo "Pulling the latest Docker images for CoUGARs"
bash scripts/update.sh
