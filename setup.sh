#!/bin/bash
#
# Sets up environment requirements on a new RPi 5
# - Run this script on a newly flashed Raspberry Pi 5. After running it, run 'compose.sh' to load in and run the most current image
# - This script can also be used to set up a new development environment on a personal machine
# - Make sure you run this from the root of the top-level repo

source scripts/utils/print.sh

echo "This script should be run from the root of the CoUGARS directory"

# Ask user for clone method choice: HTTPS or SSH
echo "Choose cloning method for repositories:"
echo "1) SSH"
echo "2) HTTPS"
read -p "Enter the number of your choice [1 or 2]: " clone_method

# Install common dependencies
printInfo "Do you want to install vim, tmux, git, chrony, and mosh"
read -p "Install common dependencies? (y/n): " install_deps


# Check vcstool
if ! [ -x "$(command -v vcs)" ]; then
    printInfo "vcstool is not installed."
    read -p "Do you want to install vcstool? (y/n): " install_vcstool
    
else
    printInfo "vcstool is already installed."
fi

# Ask if you want to copy the tmux config file
read -p "Do you want to link the tmux config file? (y/n): " link_tmux_config


read -p "Do you want to start the docker containers at the end? (y/n): " start_docker

## Would you like to build the workspaces?
read -p "Do you want to build the workspaces? (y/n): " build



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
    printWarning "Using existing vehicle namespace: $vehicle_name"
fi

bash scripts/utils/copy_templates.sh
# Check for sudo access
sudo echo "Sudo access granted for user $USER" 

# Install common dependencies
if [[ "$install_deps" == "y" || "$install_deps" == "Y" ]]; then
    printInfo "Installing common dependencies: vim, tmux, git, chrony, and mosh"
    sudo apt install -y vim tmux git chrony mosh
else
    printWarning "Skipping installation of common dependencies"
fi


if [[ "$install_vcstool" == "y" || "$install_vcstool" == "Y" ]]; then
    printInfo "Installing vcstool"
    sudo apt install vcstool
else
    printWarning "Skipping installation of vcstool. Repo imports may fail."
fi

# Set up bag directory
if [ -d "bag" ]; then
    printWarning "The bag directory already exists"
else
    mkdir bag
    sudo chmod a+w -R bag
fi

if [ "$clone_method" -eq 1 ]; then
    VCS_CLONE_METHOD=""
    printInfo "Cloning using SSH"
elif [ "$clone_method" -eq 2 ]; then
    VCS_CLONE_METHOD="-h"
    printInfo "Cloning using HTTPS"
else
    printError "Invalid clone method choice. Defaulting to SSH."
    VCS_CLONE_METHOD=""
fi
printInfo "Using vcs file suffix: $VCS_CLONE_METHOD"


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
  else
      printWarning "Docker is already installed"
  fi

  # Set up chrony config file
  if [ -f /etc/chrony/chrony.conf ]; then
      printWarning "The chrony config symlink already exists"
  else
      sudo ln -s $HOME/cougars/config/local/chrony.conf /etc/chrony/chrony.conf
  fi
else 
    ### START DEV-SPECIFIC SETUP ###

    sudo chmod a+w -R .ssh_keys
    ### END DEV-SPECIFIC SETUP ###
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

# Copy tmux config file
if [[ "$link_tmux_config" == "y" || "$link_tmux_config" == "Y" ]]; then
    ln config/local/.tmux.conf ~/.tmux.conf
    printInfo "Copied the tmux config file to ~/.tmux.conf"
    tmux source-file ~/.tmux.conf
fi

# Get rid of utf8 error
unset LC_ALL

# TODO ask if they want to do this
# Pull the latest Docker images
printInfo "Pulling the latest Docker images for CoUGARs"
bash scripts/update.sh -f $VCS_CLONE_METHOD


## Would you like to start the docker containers?
if [[ "$start_docker" == "y" || "$start_docker" == "Y" ]]; then
    bash compose.sh 
else
    printWarning "Skipping starting the docker containers"
fi
printInfo "You can start the containers by running 'bash compose.sh'"


if [[ "$build" == "y" || "$build" == "Y" ]]; then
    printInfo "Building the workspaces now"
    bash scripts/utils/build.sh -c
else
    printWarning "Skipping building the workspaces"
fi
printInfo "You can build the workspaces by running 'bash scripts/utils/build.sh'"



printInfo "Make sure to update the vehicle-specific configuration files in 'config' now"
