#! /bin/bash

#-----------------------------------------------------------------------------
# custom_container_config.sh:
# this configuration file defines bash variables to define the behavior of 
# the container deployment scripts for a specific application
#-----------------------------------------------------------------------------

##### Container Host Configuration Variables: #####

	# container user account
	CONTAINER_ACCOUNT_NAME="docker-user"

	# define the project repository name
	CONTAINER_PROJECT_FOLDER="staff-info-app"

	# define the container source directory that will be created on the container host by cloning the project repository
	CONTAINER_HOST_SOURCE_PATH="/tmp/${CONTAINER_PROJECT_FOLDER}"

	# define the container host_scripts folder on the source folder
	CONTAINER_HOST_SCRIPTS_PATH="${CONTAINER_HOST_SOURCE_PATH}/container_application_deployment/deployment_scripts/host_scripts"

	# define the container compose file path for local development deployments where local folders and mounted as volumes
	CONTAINER_COMPOSE_PATH_MOUNT="docker-compose.local.dev.yml"
	
	# define the container compose file path for testing/production deployments
	CONTAINER_COMPOSE_PATH="docker-compose.yml"

	# define the container git project URL
	CONTAINER_GIT_URL="--branch Branch_CAD_implementation git@picgitlab.nmfs.local:omi-apps/staff-info-app.git"

	# define the target directory for the container project when the container image is built
	CONTAINER_HOST_TARGET_PATH="/home/${CONTAINER_ACCOUNT_NAME}/containers/${CONTAINER_PROJECT_FOLDER}"

	# define the container source directory that contains the container source files (e.g. Dockerfile, docker-compose.yml)
	CONTAINER_HOST_SOURCE_TARGET_PATH="${CONTAINER_HOST_TARGET_PATH}/container_application_deployment"

	# define the path to the client source files
	CLIENT_CONTAINER_SOURCE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../.."

	# define the deployment script logs folder
	DEPLOYMENT_SCRIPT_LOGS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../deployment_script_logs"	

##### Container Project Configuration Variables: #####

	# define the name of the container stack
	CONTAINER_STACK_NAME="SIA_stack"

	# define the name of the container network
	CONTAINER_NETWORK_NAME="${CONTAINER_STACK_NAME}_default"

	# define the container image name
	CONTAINER_IMAGE_NAME="pifsc/${CONTAINER_PROJECT_FOLDER}"
	
	# declare an associative array with the secret name as the array element and the bash variable name as the array value
	declare -A SECRET_MAPPING_ARR=(
		# [Docker Secret Name] = "Bash Variable Name"
		["sia_db_username_secret"]="DB_USERNAME"
		["sia_db_password_secret"]="DB_PASSWORD"
	)
