#!/bin/bash

#-----------------------------------------------------------------------------
# docker_restart_container.sh:
# this host script runs as the $DOCKER_ACCOUNT_NAME to restart the docker 
# container application
#-----------------------------------------------------------------------------

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in host scripts
source ./includes/include_host_resources.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# initialize the docker target folder and build/run the container
restart_docker_project "$REBUILD_IMAGE"

# echo "$CURRENT_SCRIPT_NAME has finished running"
