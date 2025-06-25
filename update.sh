#!/bin/bash
# Created by Nelson Durrant, Sep 2024
#
# Simply pulls all avaliable updates
# - Make sure you run this from the root of the top-level repo

source config/cougarsrc.sh

echo "This script should be run from the root of the CoUGARS directory"

# Docker updates
docker pull frostlab/cougars:latest

# GitHub updates
git pull

cd ./cougars-ros2
git pull

cd ../cougars-teensy
git pull

cd ../cougars-gpio
git pull

if [ ! "$(uname -m)" == "aarch64" ]; then

  cd ../cougars-docs
  git pull

  cd ../cougars-base-station
  git pull

fi
