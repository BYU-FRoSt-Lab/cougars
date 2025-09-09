# !/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
docker build -t frostlab/cougars:gtsam -f "$script_dir/Dockerfile" "$script_dir"