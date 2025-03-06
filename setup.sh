#!/bin/bash
# Created by Nelson Durrant, Sep 2024
#
# Sets up environment requirements on a new RPi 5
# - Run this script on a newly flashed Raspberry Pi 5. After running it, run 'compose.sh' to load in and run the most current image
# - This script can also be used to set up a new development environment on a personal machine
# - Make sure you run this from the root of the top-level repo

function printInfo {
  echo -e "\033[0m\033[36m[INFO] $1\033[0m"
}

function printWarning {
  echo -e "\033[0m\033[33m[WARNING] $1\033[0m"
}

function printError {
  echo -e "\033[0m\033[31m[ERROR] $1\033[0m"
}

printWarning "This script should be run from the root of the CoUGARS directory"

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

  # Install dependencies
  sudo apt install -y vim tmux git mosh

  ### END DEV-SPECIFIC SETUP ###

fi

# Set up bag directory
if [ -d "bag" ]; then
    printWarning "The bag directory already exists"
else
    mkdir bag
fi

# TODO: update config setup
# Set up config directory
if [ -d "config" ]; then
    printWarning "The config directory already exists -- skipping copying templates"
else
    mkdir config
    cp -r templates/* config/
fi

# Set up tmux config file
if [ -f ~/.tmux.conf ]; then
    printWarning "The tmux config symlink already exists"
else
  sudo ln -s /home/frostlab/CoUGARs/config/local/.tmux.conf ~/.tmux.conf
  tmux source-file ~/.tmux.conf
fi

if [ "$(uname -m)" == "aarch64" ]; then

  ### START RT-SPECIFIC SETUP ###

  # Set up chrony config file
  if [ -f /etc/chrony/chrony.conf ]; then
      printWarning "The chrony config symlink already exists"
  else
      sudo ln -s $HOME/CoUGARs/config/local/chrony.conf /etc/chrony/chrony.conf
  fi

  # Set up udev rules
  if [ -f /etc/udev/rules.d/00-teensy.rules ]; then
      printWarning "The udev rules symlink already exists"
  else
      sudo ln -s $HOME/CoUGARs/config/local/00-teensy.rules /etc/udev/rules.d/00-teensy.rules
      sudo ln -s $HOME/CoUGARs/config/local/99-teensy.rules /etc/udev/rules.d/99-teensy.rules
      sudo ln -s $HOME/CoUGARs/config/local/99-seatrac.rules /etc/udev/rules.d/99-seatrac.rules
      sudo udevadm control --reload-rules
      sudo udevadm trigger
  fi

  ### END RT-SPECIFIC SETUP ###

else 

  ### START DEV-SPECIFIC SETUP ###

  # TODO: Maybe not needed if we do all the work in the Docker image?
  # Get the CoUGARs workspace location on the development machine
  current_dir=$(pwd)
  source_file=$current_dir/config/bash_vars.sh

  # Attempt to add the current workspace directory to the source file
  if ! grep -q "COUG_WORKSPACE_DIR" $source_file; then
    echo "export COUG_WORKSPACE_DIR=$current_dir" >> $source_file
    printInfo "Saved the CoUGARs workspace path to $source_file"
  else
    printWarning "The CoUGARs workspace path already exists in $source_file"
  fi

  # Attempt to add the source file to the local user's .bashrc
  if ! grep -q "source $source_file" ~/.bashrc; then
    echo "source $source_file" >> ~/.bashrc
    printInfo "Added automatic sourcing of bash variables to .bashrc"
  else
    printWarning "Automatic sourcing of bash variables is already set up in .bashrc"
  fi

  # Copy repos from GitHub
  git clone https://github.com/BYU-FRoSt-Lab/cougars-docs.git
  git clone https://github.com/BYU-FRoSt-Lab/cougars-base-station.git

  ### END DEV-SPECIFIC SETUP ###

fi

# Get rid of utf8 error
unset LC_ALL

# Copy repos from GitHub
git clone https://github.com/BYU-FRoSt-Lab/cougars-ros2.git
git clone https://github.com/BYU-FRoSt-Lab/cougars-teensy.git
git clone https://github.com/BYU-FRoSt-Lab/cougars-gpio.git

printInfo "Make sure to update the vehicle-specific configuration files in "config" now"
