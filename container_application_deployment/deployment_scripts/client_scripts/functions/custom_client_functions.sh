#!/bin/bash

#-----------------------------------------------------------------------------
# custom_client_functions.sh:
# this file defines custom client functions that are configured specifically 
# this container application
#-----------------------------------------------------------------------------

# function that defines the environment variable bash string that will define bash variable arguments for inclusion when the client run/build container bash scripts execute
# this function accepts no parameters
function client_deploy_define_env_vars_string()
{
	# validate the bash variable values
	if ! validate_required_vars	"DB_HOST" "DB_SERVICE_NAME" "CONTAINER_BUILD_IMAGE"; then
        echo "ERROR: client_deploy_define_env_vars_string() function required bash variable validation failed" >&2
        return 1
	fi
	# build the list of environment variable declarations passed to the bash script. Expand variables before it is passed to the bash function
	local env_vars_string="DB_HOST=\"${DB_HOST}\" DB_SERVICE_NAME=\"${DB_SERVICE_NAME}\" CONTAINER_BUILD_IMAGE=\"${CONTAINER_BUILD_IMAGE}\""

	# return the string
	echo "${env_vars_string}"
}

# function that loads the environment-specific deployment configuration file
function client_load_deploy_config_file ()
{
	# validate the bash variable values
	if ! validate_required_vars	"CLIENT_CONTAINER_SOURCE_PATH" "CONTAINER_ENV_NAME"; then
        echo "ERROR: client_load_deploy_config_file() function required bash variable validation failed" >&2
        return 1
	fi

	# load the bash variables for the runtime configuration (/container_application_deployment/deployment_scripts/config)
	source "${CLIENT_CONTAINER_SOURCE_PATH}/deployment_scripts/config/deploy_config.${CONTAINER_ENV_NAME}.sh"
}

# function that loads the environment-specific client secret file
function client_load_secret_file ()
{
	# validate the bash variable values
	if ! validate_required_vars	"CLIENT_CONTAINER_SOURCE_PATH" "CONTAINER_ENV_NAME"; then
        echo "ERROR: client_load_secret_file() function required bash variable validation failed" >&2
        return 1
	fi

	# load the oracle credentials into bash variables (/container_application_deployment/secrets/${CONTAINER_ENV_NAME})
	source "${CLIENT_CONTAINER_SOURCE_PATH}/secrets/${CONTAINER_ENV_NAME}/secrets.sh"
}

# declare the environment variables for local deployments
function client_export_env_vars ()
{
	# validate the bash variable values
	if ! validate_required_vars	"DB_HOST" "DB_SERVICE_NAME" "CONTAINER_BUILD_IMAGE"; then
        echo "ERROR: client_export_env_vars() function required bash variable validation failed" >&2
        return 1
	fi

	# load the bash database variables as environment variables:
	export DB_HOST
	export DB_SERVICE_NAME
	export CONTAINER_BUILD_IMAGE
}