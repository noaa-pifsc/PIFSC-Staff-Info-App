#! /bin/bash

#-----------------------------------------------------------------------------
# container_config.sh:
# this configuration file defines bash variables to define the behavior of 
# the container deployment scripts for all applications after the custom 
# configuration file is included
#-----------------------------------------------------------------------------

##### Container Host Configuration Variables: #####

	# define the container source directory that will be created on the container host by cloning the project repository
	HOST_SOURCE_PATH="/tmp/${PROJECT_FOLDER}"

	# define the container host_scripts folder on the source folder
	HOST_SCRIPTS_PATH="${HOST_SOURCE_PATH}/container_application_deployment/deployment_scripts/host_scripts"

	# define the container source directory that contains the container source files (e.g. Dockerfile, docker-compose.yml)
	CONTAINER_TARGET_PATH="${HOST_TARGET_PATH}/container_application_deployment"
