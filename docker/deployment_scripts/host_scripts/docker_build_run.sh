#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

echo "running docker_build_run.sh"

# include the host functions
source ./functions/host_functions.sh
source ./functions/custom_host_functions.sh
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# initialize the docker target folder and build/run the container
initialize_run_docker_project

