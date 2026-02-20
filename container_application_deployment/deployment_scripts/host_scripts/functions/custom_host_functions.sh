#!/bin/bash

#-----------------------------------------------------------------------------
# custom_host_functions.sh:
# this file defines custom host functions that are used for this specific 
# container application for container deployments (intended for remote container host 
# scenarios)
#-----------------------------------------------------------------------------

# function to copy the necessary files to deploy the container application from the specified subdirectory of $CONTAINER_HOST_SOURCE_PATH to the $CONTAINER_HOST_TARGET_PATH. 
# this function accepts no parameters
# Usage:
# host_prepare_container_target_dir
function host_prepare_container_target_dir ()
{
	# validate the bash variable values
	if ! validate_required_vars	"CONTAINER_HOST_TARGET_PATH" "CONTAINER_HOST_SOURCE_PATH"; then
        echo "ERROR: host_prepare_container_target_dir() function required bash variable validation failed" >&2
        return 1
	fi

	# remove the files in the container container target directory
	rm -rf "${CONTAINER_HOST_TARGET_PATH}"/*

	# copy the container files to the root $CONTAINER_HOST_TARGET_PATH
	rsync -a "${CONTAINER_HOST_SOURCE_PATH}"/container_application_deployment/* "${CONTAINER_HOST_TARGET_PATH}"/container_application_deployment
	rsync -a "${CONTAINER_HOST_SOURCE_PATH}"/modules/* "${CONTAINER_HOST_TARGET_PATH}"/modules
}

# function that defines the environment variable bash block that will define the environment variables for inclusion when the build/run container bash scripts execute
# this function accepts no parameters
function host_deploy_define_env_vars_block()
{
	# validate the bash variable values
	if ! validate_required_vars "DB_HOST" "DB_SERVICE_NAME" "CONTAINER_BUILD_IMAGE"; then
        echo "ERROR: host_deploy_define_env_vars_block() function required bash variable validation failed" >&2
        return 1
	fi
	# build the list of environment variable declarations passed to the bash script, in multi-line format for readability. Expand variables before it is passed to the bash function
	local env_vars_block="
	export DB_HOST='${DB_HOST}'
	export DB_SERVICE_NAME='${DB_SERVICE_NAME}'
	export CONTAINER_BUILD_IMAGE='${CONTAINER_BUILD_IMAGE}'
	"

	# return the multiline string
	echo "${env_vars_block}"
}