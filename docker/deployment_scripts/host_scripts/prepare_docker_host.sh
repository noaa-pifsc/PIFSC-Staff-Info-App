#!/bin/bash

#-----------------------------------------------------------------------------
# prepare_docker_host.sh:
# this host script prepares the $DOCKER_SOURCE_DIR directory with the docker 
# container source files so the docker image can be built and deployed on the 
# docker host
#-----------------------------------------------------------------------------

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in host scripts
source ./includes/include_host_resources.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# convert the line endings for all .sh files in the parent folder
convert_dos2unix "../"


# prepre the docker preparation folder
prepare_docker_prep_folder

echo "$CURRENT_SCRIPT_NAME has finished running"
