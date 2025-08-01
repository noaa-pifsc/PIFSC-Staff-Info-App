#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

echo "running define secrets script"

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

# set the secret database values from the bash variables
set_db_secrets


# unset the configuration variables after they have been used
unset_config_variables
