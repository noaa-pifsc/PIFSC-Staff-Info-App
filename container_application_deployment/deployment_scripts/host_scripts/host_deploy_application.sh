#!/bin/bash

#-----------------------------------------------------------------------------
# host_deploy_application.sh:
# this host script runs a script as the $CONTAINER_ACCOUNT_NAME to build the 
# container image and run the container on the container host by executing 
# host_deploy_application_elev_privs.sh
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# declare the function arguments
declare -A FUNC_ARGS=(
		["container_host_scripts_path"]="${CONTAINER_HOST_SCRIPTS_PATH}"
		["container_account_name"]="${CONTAINER_ACCOUNT_NAME}"
		["container_host_source_path"]="${CONTAINER_HOST_SOURCE_PATH}"
		["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
		["host_script_name"]="host_deploy_application_elev_privs.sh"
		["env_vars_block"]="$(host_deploy_define_env_vars_block)"
		["calling_script_path"]="${0}"
		["container_build_image"]="${CONTAINER_BUILD_IMAGE}"
		["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
	)

#initiate the build/run process for the container using a privileged account on the host
host_deploy_container "FUNC_ARGS"