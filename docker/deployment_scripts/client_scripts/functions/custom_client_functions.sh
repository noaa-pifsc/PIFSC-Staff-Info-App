#!/bin/bash

#-----------------------------------------------------------------------------
# custom_client_functions.sh:
# this file defines custom client functions that are used for this specific 
# docker application for docker deployments (intended for remote docker host 
# scenarios)
#-----------------------------------------------------------------------------



# this function prepares and executes the client deployment scripts
# this function accepts 1 parameter: the environment name (dev, test, prod)
# Usage:
#   prepare_deployment_script "$1"
function prepare_execute_deployment_script ()
{
	echo "prepare the docker source files and deploy the container"
	
	local passed_env_name="$1"

	# save/prompt for environment name and SSH username
	set_env_var "$passed_env_name" 

	# recursively convert the line endings for all .sh files in the root folder of the repository
	convert_dos2unix "../../../"

	# load the bash variables for the runtime configuration
	source ../config/deploy_config.$ENV_NAME.sh
	
	# Prepare the docker host by creating directories and cloning the repository
	prepare_docker_host "yes"

	# load the oracle credentials into bash variables
	source ../../secrets/$ENV_NAME/secrets.sh

	# compile stdin credential/configuration variables:
	CONFIG_DATA=$(encode_config_data)

	# unset the sensitive bash variables so they can't be reused
	unset_config_variables

	echo "define the docker secrets"

	# define the secrets and specify the bash variable values as stdin
	exec_remote_cmd_with_stdin "$CONFIG_DATA" "bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/define_secrets.sh"

	# unset the CONFIG_DATA now that the ssh call has completed
	unset CONFIG_DATA

	echo "deploy the container"

	# execute the deployment/upgrade script on the host server and pass the DB_SERVICE_NAME and DB_HOST bash variable values
	exec_remote_cmd "DB_HOST=\"$DB_HOST\" DB_SERVICE_NAME=\"$DB_SERVICE_NAME\" bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/build_run_container.sh"

	echo "the docker deployment script has finished executing"
}


# this function prepares the docker host by creating the temporary directory structure (defined by ${DOCKER_SOURCE_DIR}), cloning the project repository, and optionally copying project dependencies from the PHP shared library repository.  This function accepts no parameters
# Usage:
# prepare_docker_host
function prepare_docker_host ()
{
	echo "prepare the docker host by cloning the application repository: $DOCKER_GIT_URL"

	echo "create the directory path ('$DOCKER_SOURCE_DIR') for the initial deployment scripts"

		# remove the temporary directory, create the directory path ('$DOCKER_SOURCE_DIR') for the initial deployment scripts, clone the repository, and update the file permissions
	exec_remote_cmd "rm -rf '${DOCKER_SOURCE_DIR}' && mkdir -p '${DOCKER_SOURCE_DIR}' && git clone --recurse-submodules ${DOCKER_GIT_URL} ${DOCKER_SOURCE_DIR} && chmod -R 755 $DOCKER_SOURCE_DIR"
}




# this function prepares and executes the host scripts that restart the docker app
# this function accepts 2 parameters: the environment name (dev, test, prod), and rebuild image? (yes, no) to rebuild the image (yes) or reuse the existing image (no)
# Usage:
#   prepare_deployment_script "dev" "yes"
#   prepare_deployment_script "prod" "no"
function prepare_execute_restart_script ()
{
	echo "restart the container on the docker host"
	
	# save/prompt for environment name
	set_env_var "$1" 

#	echo "The value of ENV_NAME is: $ENV_NAME"

	# save/prompt for the rebuild docker image boolean value 
	set_rebuild_var "$2"

#	echo "The value of REBUILD_IMAGE is: $REBUILD_IMAGE"

	# recursively convert the line endings for all .sh files in the root folder of the repository
	convert_dos2unix "../../../"

	# load the bash variables for the runtime configuration
	source ../config/deploy_config.$ENV_NAME.sh
	
	# Prepare the docker host by creating directories and cloning the repository (do not include the php shared library since it will not be used in a docker container restart scenario)
	prepare_docker_host "no"

	# execute the deployment/upgrade script on the host server and pass the DB_SERVICE_NAME and DB_HOST bash variable values
	exec_remote_cmd "DB_HOST=\"$DB_HOST\" DB_SERVICE_NAME=\"$DB_SERVICE_NAME\" REBUILD_IMAGE=\"$REBUILD_IMAGE\" bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/restart_container.sh"

	echo "the container restart script has finished executing"
}