#!/bin/bash

# this function prepares and executes the client deployment scripts
# this function accepts 1 parameter: the environment name (dev, test, prod)
# Usage:
#   prepare_deployment_script "$1"
function prepare_execute_deployment_script ()
{
	local passed_env_name="$1"

	# save/prompt for environment name and SSH username
	set_env_var "$passed_env_name" 

#	echo "The value of ENV_NAME is: $ENV_NAME"

	# convert all the .sh files in the parent directory to unix line endings
	convert_dos2unix "../"

	# load the bash variables for the runtime configuration
	source ../config/deploy_config.$ENV_NAME.sh
	source ../config/docker_host_config.sh
	
	# Prepare the docker host by creating directories and cloning the repository
	prepare_docker_host

	# load the oracle credentials into bash variables
	source ../../secrets/$ENV_NAME/secrets.sh

	# compile stdin credential/configuration variables:
	CONFIG_DATA=$(encode_config_data)

	# unset the sensitive bash variables so they can't be reused
	unset_config_variables


	# define the secrets and specify the bash variable values as stdin
	exec_remote_cmd_with_stdin "$CONFIG_DATA" "bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/define_secrets.sh"

	# unset the CONFIG_DATA now that the ssh call has completed
	unset CONFIG_DATA


	# execute the deployment/upgrade script on the host server and pass the DB_SERVICE_NAME and DB_HOST bash variable values
	exec_remote_cmd "DB_HOST=\"$DB_HOST\" DB_SERVICE_NAME=\"$DB_SERVICE_NAME\" bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/initiate_docker.sh"

	echo "The $CURRENT_SCRIPT_NAME script finished executing"

}


# function that prepares the docker host by creating the temporary directory structure, copying the initial .sh and .env files for the host and executes the prepare_docker_host.sh script.  This function accepts no parameters
# Usage:
# prepare_docker_host
function prepare_docker_host ()
{
	echo "create the directory path ('$DOCKER_SOURCE_DIR') for the initial deployment scripts"

	# remove the temporary directory, create the directory path ('$DOCKER_SOURCE_DIR') for the initial deployment scripts, and clone the repository
	exec_remote_cmd "rm -rf '${DOCKER_SOURCE_DIR}' && mkdir -p '${DOCKER_SOURCE_DIR}' && git clone ${DOCKER_GIT_URL} ${DOCKER_SOURCE_DIR}"
	
	# prepare the docker project (clone shared library and copy files into designated folder in project repository):
	exec_remote_cmd "bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/prepare_docker_host.sh"

}
