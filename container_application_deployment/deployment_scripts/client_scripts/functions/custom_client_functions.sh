#!/bin/bash

#-----------------------------------------------------------------------------
# custom_client_functions.sh:
# this file defines custom client functions that are configured specifically 
# this container application
#-----------------------------------------------------------------------------

# function that defines the environment variable bash string that will define bash variable arguments for inclusion when the client run/build container bash scripts execute
# the function accepts the following arguments:
# 1: build image (yes, no)
function proj_client_deploy_define_env_vars_string()
{
	# store the function arguments in local variables
	local BUILD_IMAGE="${1}"

	# required bash variable validation
	if ! cds_shared_validate_required_vars	"DB_HOST" "DB_SERVICE_NAME" "BUILD_IMAGE"; then
        echo "Error: proj_client_deploy_define_env_vars_string() function required bash variable validation failed" >&2
        return 1
	fi

	# Dynamically validate and strictly format the SSH string
	cds_shared_generate_ssh_env_vars_string "DB_HOST" "DB_SERVICE_NAME" "BUILD_IMAGE"
}

# function to declare the environment variables for local deployments
# the function accepts the following arguments:
# 1: build image (yes, no)
function proj_client_export_env_vars ()
{
	# store the function arguments in global variables
	BUILD_IMAGE="${1}"

	# required bash variable validation
	if ! cds_shared_validate_required_vars	"DB_HOST" "DB_SERVICE_NAME" "BUILD_IMAGE"; then
        echo "Error: proj_client_export_env_vars() function required bash variable validation failed" >&2
        return 1
	fi

	# export the bash variables as environment variables:
	export DB_HOST DB_SERVICE_NAME BUILD_IMAGE
}


# function that loads the secret and configuration files
# the function accepts the following arguments:
# 1: build path
# 2: container environment name (dev, test, prod)
function proj_client_load_config_secrets ()
{
	# store the function arguments in local variables
	local build_path="${1}"
	local env_name="${2}"

	# required bash variable validation
	if ! cds_shared_validate_required_vars	"build_path" "env_name"; then
        echo "Error: proj_client_load_config_secrets() function required required function argument validation failed" >&2
        return 1
	fi
	
	# load the bash variables for the runtime configuration (/container_application_deployment/deployment_scripts/config)
	source "${build_path}/deployment_scripts/config/deploy_config.${env_name}.sh"
	
	# load the database credentials and API key into bash variables (/container_application_deployment/secrets/${env_name})
	source "${build_path}/secrets/${env_name}/secrets.sh"
}