#!/bin/bash

# function that loads the function parameter to the ENV_NAME variable and loads the environment variables from docker_host.env
# the first parameter is the script path that was executed
# Usage:
# initialize_docker_env_var "$0"
function initialize_docker_env_var ()
{
	# retrieve the current script name that was originally invoked
	get_script_name_from_path "$1"

	echo "running $CURRENT_SCRIPT_NAME"

	# load the configuration variables
	source ../config/docker_host_config.sh
}

