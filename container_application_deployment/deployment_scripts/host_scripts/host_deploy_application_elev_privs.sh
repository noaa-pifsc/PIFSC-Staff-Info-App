#!/bin/bash

#-----------------------------------------------------------------------------
# host_deploy_application_elev_privs.sh:
# this host script runs as the $CONTAINER_ACCOUNT_NAME to build and run 
# the container application
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# declare the function arguments
declare -A FUNC_ARGS=(
		["container_target_path"]="${CONTAINER_HOST_SOURCE_TARGET_PATH}"
		["container_image_name"]="${CONTAINER_IMAGE_NAME}"
		["container_stack_name"]="${CONTAINER_STACK_NAME}"
		["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
		["container_network_name"]="${CONTAINER_NETWORK_NAME}"
		["build_image"]="${BUILD_IMAGE}"
		["calling_script_path"]="${0}"
	)

# deploy the container in stack mode
host_deploy_container_elev_privs "FUNC_ARGS"