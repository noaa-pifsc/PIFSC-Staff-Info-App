#! /bin/bash

#-----------------------------------------------------------------------------
# initial_container_config.sh:
# this configuration file defines bash variables to define the behavior of 
# the container deployment scripts for all applications. It is intended to be 
# included before any custom configuration definition scripts.
#-----------------------------------------------------------------------------

##### Container Host Configuration Variables: #####

	# define the path to the client source files (/container_application_deployment folder)
	BUILD_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../.."

	# define the deployment script logs folder
	DEPLOYMENT_SCRIPT_LOGS="${BUILD_PATH}/deployment_script_logs"	

	# determine where the repository root path based on the configuration file location
	REPO_ROOT_PATH="${BUILD_PATH}/.."