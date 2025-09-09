#!/bin/bash
#
# Usage:
#   bash compose.sh [-v VERSION] [down]
#   -v VERSION : Set the version for Docker images (exported as VERSION)
#   down       : Stop all docker images
# Notes:
#   - Make sure to run this from the root of the top-level repo

echo "This script should be run from the root of the CoUGARS directory"
source scripts/utils/print.sh
cd docker

# Default Compose file
COMPOSE_FILE="docker-compose.yaml"

# Parse arguments
while getopts ":v:" opt; do
  case $opt in
    v)
      export VERSION="-v${OPTARG}"
      printInfo "Using version: $VERSION"
      COMPOSE_FILE="docker-compose-runtime.yaml"
      ;;
    \?)
      printWarning "Invalid option: -$OPTARG"
      ;;
  esac
done

# Remove processed options from $@
shift $((OPTIND -1))

case $1 in
  "down")
    printWarning "Stopping all docker images"
    docker compose -f "$COMPOSE_FILE" down
    ;;
  *)
    # Check the system architecture
    if [ "$(uname -m)" == "aarch64" ]; then
        printInfo "Loading the runtime image..."
        containers=("cougars")
    else
        containers=("cougars" "cougars_base")
        # TODO for the GPU CONTAINER
        # # check if gpu is available
        # if command -v nvidia-smi &> /dev/null; then
        #     printInfo "NVIDIA GPU detected. Loading the GPU-enabled development image..."
        #     containers=("cougars" "cougars_base" "cougars_sim")
        # else
        #     printInfo "No NVIDIA GPU detected. Loading the CPU-only development image..."
        # fi
    fi
    docker compose -f "$COMPOSE_FILE" up -d "${containers[@]}"
    ;;
esac

cd ..