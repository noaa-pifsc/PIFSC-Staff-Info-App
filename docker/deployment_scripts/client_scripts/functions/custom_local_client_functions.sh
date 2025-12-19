#!/bin/bash

#-----------------------------------------------------------------------------
# custom_local_client_functions.sh:
# this file defines custom client functions that are used for this specific 
# docker application for local client docker deployments (intended 
# for development/testing purposes using docker desktop)
#-----------------------------------------------------------------------------

# function to deploy a container locally using docker desktop.  The function accepts two parameters, the first is the environment name (dev, test, prod), the second is execution mode (mount = mounting source code directories, stack = deploying as docker stack with secrets).  If either/both of the parameters are not specified the script will prompt the user for the parameter values
# Usage:
#   deploy_container_locally "dev" "mount"
#   deploy_container_locally "test" "stack"
function deploy_container_locally ()
{
	echo "deploy the container locally"

	# save/prompt for environment name
	set_env_var "$1" 
	
	# save/prompt for execution mode
	set_exec_mode_var "$2"

	# load the bash variables for the runtime configuration
	source ../config/deploy_config.$ENV_NAME.sh
	
	# load the oracle credentials as environment variables for local development purposes
	source ../../secrets/$ENV_NAME/secrets.sh

	# load the bash database variables as environment variables:
	export DB_HOST
	export DB_SERVICE_NAME




	# change directory into the docker folder that contains the Dockerfile and .yml files
	cd ../../

	# check if this is a mounted or stack deployment:
    if [[ $EXEC_MODE == "mount" ]]; then
		# this is a mounted directory deployment
		echo "deploy the container with docker compose for development purposes"

		# export the variable names defined in the values of the SECRET_MAPPING_ARR array
		export_vars_from_mapping SECRET_MAPPING_ARR
		
		# stop and remove any running container and build/run the container from the source code
		build_deploy_container "docker-compose.local.dev.yml"

    else
		# use docker stack and secrets to test if the code is working for a secure docker host deployment

		echo "deploy the container with docker swarm to test docker secrets"

		# stop the container if it's running so the secrets can be defined/updated
		remove_docker_stack "$DOCKER_STACK_NAME"

		# set the docker secrets for the database information based on the bash variables
		set_db_secrets

		# unset the bash variables used to define the secret values
		unset_config_variables

		# waits for the docker network to be removed
		wait_for_docker_network_removal "$DOCKER_NETWORK_NAME"

		# build the docker image, save the docker image, deploy the image as a docker stack
		build_deploy_docker_stack "$DOCKER_IMAGE_NAME" "$DOCKER_STACK_NAME" yes

    fi

	echo "the local docker deployment script has finished executing"

}

