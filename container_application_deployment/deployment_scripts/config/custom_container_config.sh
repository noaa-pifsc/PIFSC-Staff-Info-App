#! /bin/bash

#-----------------------------------------------------------------------------
# custom_container_config.sh:
# this configuration file defines bash variables to define the behavior of 
# the container deployment scripts for a specific application
#-----------------------------------------------------------------------------

##### Container Host Configuration Variables: #####

	# container privileged user account that can run container commands
	PRIV_USER="docker-user"

	# define the project repository name
	PROJECT_FOLDER="staff-info-app"

	# define the container git project URL
	GIT_URL="--branch Branch_CAD_implementation git@github.com:noaa-pifsc/PIFSC-Staff-Info-App.git"

	# define the target directory for the container project when the container image is built
	HOST_TARGET_PATH="/home/${PRIV_USER}/containers/${PROJECT_FOLDER}"

##### Container Project Configuration Variables: #####

	# define the name of the container stack
	STACK_NAME="SIA_stack"

	# define the name of the container network
	NETWORK_NAME="${STACK_NAME}_default"

	# define the container image name
	IMAGE_NAME="pifsc/${PROJECT_FOLDER}"

	# define the container compose file path for local development deployments where local folders and mounted as volumes
	COMPOSE_MOUNT_PATH="${BUILD_PATH}/docker-compose.local.dev.yml"
	
	# define the container compose file path for testing/production deployments
	COMPOSE_PATH="${BUILD_PATH}/docker-compose.yml"

	# define the container image specification file path (e.g. Dockerfile) for container deployments
	IMAGE_SPEC_PATH="${BUILD_PATH}/Dockerfile"
	
	# define the container build context (e.g. ..)
	BUILD_CONTEXT="${BUILD_PATH}/.."
	
	# declare an associative array with the secret name as the array element and the bash variable name as the array value
	declare -A SECRET_MAPPING_ARR=(
		# [Docker Secret Name] = "Bash Variable Name"
		["sia_db_username_secret"]="DB_USERNAME"
		["sia_db_password_secret"]="DB_PASSWORD"
	)
