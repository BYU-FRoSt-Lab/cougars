#!/bin/bash
# Created by Nelson Durrant, Sep 2024
#
# Sets up environment requirements on a new RPi 5
# - Run this script on a newly flashed Raspberry Pi 5. After running it, run 'compose.sh' to load in and run the most current image
# - This script can also be used to set up a new development environment on a personal machine
# - Make sure you run this from the root of the top-level repo

source config/cougarsrc.sh

echo "This script should be run from the root of the CoUGARS directory"


# Ask user for clone method choice: HTTPS or SSH
echo "Choose cloning method for repositories:"
echo "1) SSH"
echo "2) HTTPS"
read -p "Enter the number of your choice [1 or 2]: " clone_method

if [ "$clone_method" -eq 1 ]; then
    CLONE_PREFIX="git@github.com:BYU-FRoSt-Lab"
    printInfo "Cloning using SSH"
elif [ "$clone_method" -eq 2 ]; then
    CLONE_PREFIX="https://github.com/BYU-FRoSt-Lab"
    printInfo "Cloning using HTTPS"
else
    printError "Invalid choice. Defaulting to SSH."
    CLONE_PREFIX="git@github.com:BYU-FRoSt-Lab"
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
  sudo apt install -y vim tmux chrony git mosh

  ### END RT-SPECIFIC SETUP ###

else

  ### START DEV-SPECIFIC SETUP ###

  printInfo "Setting up CoUGARs on a development machine"

  printInfo "Do you want to install vim, tmux, and mosh"
  # Install dependencies
  sudo apt install vim tmux git mosh

  ### END DEV-SPECIFIC SETUP ###
fi

# Set up bag directory
if [ -d "bag" ]; then
    printWarning "The bag directory already exists"
else
    mkdir bag
fi

# Set up config directory
if [ -d "config" ]; then
    printWarning "The config directory already exists -- skipping copying templates"
else
    mkdir config
    cp -r templates/* config/
fi

# TODO we will setup tmux inside the container, so this is not needed
# # Set up tmux config file
# if [ -f ~/.tmux.conf ]; then
#     printWarning "The tmux config symlink already exists"
# else
#   # TODO This isnt gonna work if the user is not frostlab

#   sudo ln -s /home/frostlab/cougars/config/local/.tmux.conf ~/.tmux.conf
#   tmux source-file ~/.tmux.conf
# fi

if [ "$(uname -m)" == "aarch64" ]; then

  ### START RT-SPECIFIC SETUP ###

  # Set up chrony config file
  if [ -f /etc/chrony/chrony.conf ]; then
      printWarning "The chrony config symlink already exists"
  else
      sudo ln -s $HOME/cougars/config/local/chrony.conf /etc/chrony/chrony.conf
  fi

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

  ### END RT-SPECIFIC SETUP ###

else 

  ### START DEV-SPECIFIC SETUP ###

  # Copy repos from GitHub
  git clone $CLONE_PREFIX/cougars-docs.git
  git clone $CLONE_PREFIX/cougars-base-station.git
  sudo chmod a+w -R cougars-docs cougars-base-station
  sudo chmod a+w -R .ssh_keys 

  ### END DEV-SPECIFIC SETUP ###

fi

# Get rid of utf8 error
unset LC_ALL

# Copy repos from GitHub
git clone $CLONE_PREFIX/cougars-ros2.git
git clone $CLONE_PREFIX/cougars-teensy.git
git clone $CLONE_PREFIX/cougars-gpio.git

printInfo "Make sure to update the vehicle-specific configuration files in "config" now"

# TODO add the prompt to ask if the user wants to do this
sudo chmod a+w -R cougars-ros2 cougars-teensy cougars-gpio
sudo chmod a+w -R bag
