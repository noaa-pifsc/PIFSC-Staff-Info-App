#!/bin/bash

#-----------------------------------------------------------------------------
# custom_host_functions.sh:
# this file defines custom host functions that are used for this specific 
# container application for container deployments (intended for remote container host 
# scenarios)
#-----------------------------------------------------------------------------

# function to copy the necessary files to deploy the container application from the specified subdirectory of $container source path and target path 
# the function accepts the following arguments:
# 1: source path containing the container files
# 2: target path that will be used to build the container
function proj_host_prepare_container_target_dir ()
{
	local source_path="${1}"
	local target_path="${2}"

	# required bash variable validation
	if ! cds_shared_validate_required_vars	"target_path" "source_path"; then
        echo "Error: proj_host_prepare_container_target_dir() function required bash variable validation failed" >&2
        return 1
	fi

	# remove the files in the container container target directory
	rm -rf "${target_path}"/*

	# copy the container files to the root $target_path
	rsync -a "${source_path}"/src/* "${target_path}"/src
	rsync -a "${source_path}"/container_application_deployment/* "${target_path}"/container_application_deployment
	rsync -a "${source_path}"/modules/* "${target_path}"/modules
}

# function that defines the environment variable bash block that will define the environment variables for inclusion when the build/run container bash scripts execute
# this function accepts no parameters
function proj_host_define_env_vars_block()
{
	# Validates the arguments, securely quote values, and print the multi-line block
	cds_shared_generate_export_env_vars_block "DB_HOST" "DB_SERVICE_NAME" "BUILD_IMAGE" "REM_VOL"
}