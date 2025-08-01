#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

echo "running docker define secrets script"

# include the shell script functions
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh
source ./functions/host_functions.sh
source ./functions/custom_host_functions.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# process the stdin configuration data: parse and store in variables, construct the
# process_stdin_config_data

# read the key/value pairs from STDIN and store them in bash variables
parse_config_data


# stop the container if it's running so the secrets can be defined/updated
docker stack rm pifsc/staff-info-app


# set the docker secrets for the database information based on the parsed configuration data from STDIN
set_db_secrets


# unset bash variables specified by STDIN
unset_config_variables
