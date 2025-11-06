#!/bin/bash

#-----------------------------------------------------------------------------
# docker_define_secrets.sh:
# this host script runs as the $DOCKER_ACCOUNT_NAME to define the docker 
# secrets used by the docker container application
#-----------------------------------------------------------------------------

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in host scripts
source ./includes/include_host_resources.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# process the stdin configuration data: parse and store in variables, construct the
# process_stdin_config_data

# read the key/value pairs from STDIN and store them in bash variables
parse_config_data

# stop the container if it's running so the secrets can be defined/updated
docker stack rm "$DOCKER_STACK_NAME"


# set the docker secrets for the database information based on the parsed configuration data from STDIN
set_db_secrets


# unset bash variables specified by STDIN
unset_config_variables

# echo "$CURRENT_SCRIPT_NAME has finished running"

