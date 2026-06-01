#!/bin/bash

#-----------------------------------------------------------------------------
# custom_client_functions.sh:
# this file defines custom client functions that are configured specifically 
# this container application
#-----------------------------------------------------------------------------

# function that defines the custom environment variable bash string that will define bash variable arguments for inclusion when the client run/build container bash scripts execute
# the function accepts no arguments
function proj_client_custom_deploy_define_env_vars_string()
{
	# there are no custom environment variables that need to be exported for the SIA, return 0:
	return 0
}

# function to declare the custom environment variables for local deployments
# the function accepts no arguments
function proj_client_custom_export_env_vars ()
{
	# there are no custom environment variables that need to be exported for the SIA, return 0:
	return 0
}

# function that loads the secret and configuration files
# the function accepts the following arguments:
# 1: build path
# 2: container environment name (dev, test, prod)
function proj_client_custom_load_config_secrets ()
{
	# store the function arguments in local variables
	local build_path="${1}"
	local env_name="${2}"

	# required bash variable validation
	if ! cds_shared_validate_required_vars	"build_path" "env_name"; then
        echo "Error: ${FUNCNAME[0]}() function required required function argument validation failed" >&2
        return 1
	fi
	
	# load the bash variables for the runtime configuration (/container_application_deployment/deployment_scripts/config)
	source "${build_path}/deployment_scripts/config/deploy_config.${env_name}.sh"
	
	# load the database credentials and API key into bash variables (/container_application_deployment/secrets/${env_name})
	source "${build_path}/secrets/${env_name}/secrets.sh"
}