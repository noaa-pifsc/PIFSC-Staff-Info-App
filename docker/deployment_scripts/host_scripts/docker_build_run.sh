#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include the host functions
source ./functions/host_functions.sh
source ./functions/custom_host_functions.sh
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"


echo "The value of DB_HOST is: $DB_HOST"
echo "The value of DB_SERVICE_NAME is: $DB_SERVICE_NAME"

# initialize the docker target folder and build/run the container
initialize_run_docker_project

