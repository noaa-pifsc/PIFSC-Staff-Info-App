#!/bin/bash

#-----------------------------------------------------------------------------
# client_functions.sh:
# this file defines client functions that are used for this specific 
# container application for container deployments, these do not need to 
# be modified across individual container apps
#-----------------------------------------------------------------------------


# this function prepares and executes the client deployment scripts
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# env_name: (optional) the environment name (dev, test, prod)
# deploy_dest: (optional) deployment destination (local, server)
# build_image: (optional) build_image (yes = the container image is built and then run, no = the container is restarted using the existing container image)
# run_mode: (optional) container run mode (mount = mounting source code directories, stack = deploying as container stack with secrets) (when deplyment destination = server this argument is ignored)
# rem_vol: flag to indicate if the associated volumes should be removed (yes) or not (no)
function proj_client_deploy_container ()
{
	echo "prepare the container source files and deploy the container"
	
	# store the function array argument
	local arg_array="${1}"
	
    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: proj_client_deploy_container() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# required bash variable validation
	if ! cds_shared_validate_required_vars	"DEPLOYMENT_SCRIPT_LOGS" "BUILD_PATH" "SECRET_MAPPING_VAR_NAME" "COMPOSE_MOUNT_PATH" "IMAGE_NAME" "STACK_NAME" "NETWORK_NAME" "GIT_URL" "SECRET_DATA_VAR_NAME" "HOST_SOURCE_PATH" "HOST_SCRIPTS_PATH" "COMPOSE_PATH" "IMAGE_SPEC_PATH" "BUILD_CONTEXT" "CONTAINER_APP_PORT"; then
        echo "Error: proj_client_deploy_container() function required bash variable validation failed" >&2
        return 1
	fi
	
	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# declare the function arguments for cad_client_process_runtime_arguments()
	local -A runtime_args=(
			["log_path"]="${DEPLOYMENT_SCRIPT_LOGS}"
			["env_name"]="${arg_ref[env_name]}"
			["deploy_dest"]="${arg_ref[deploy_dest]}"
			["run_mode"]="${arg_ref[run_mode]}"
			["build_image"]="${arg_ref[build_image]}"
			["repo_root"]="${REPO_ROOT_PATH}"
			["rem_vol"]="${arg_ref[rem_vol]}"
		)
	
	#process/prompt the user for runtime values
	cad_client_process_runtime_arguments "runtime_args"

	# load the client secrets and server configuration files
	proj_client_load_config_secrets "${BUILD_PATH}" "${runtime_args[env_name]}"

	# enforce an EXIT trap immediately after loading secrets to guarantee memory sanitization. If the script errors out or is manually aborted, the sensitive globals will be securely wiped.
	trap "cds_shared_unset_secret_variables '${SECRET_MAPPING_VAR_NAME}'" EXIT
	
	# declare the function arguments
	local -A deploy_args=(
		["deploy_dest"]="${runtime_args[deploy_dest]}"
		["build_path"]="${BUILD_PATH}"
		["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
		["compose_mount_path"]="${COMPOSE_MOUNT_PATH}"
		["image_name"]="${IMAGE_NAME}"
		["build_image"]="${runtime_args[build_image]}"
		["stack_name"]="${STACK_NAME}"
		["network_name"]="${NETWORK_NAME}"
		["git_url"]="${GIT_URL}"
		["secret_var"]="${SECRET_DATA_VAR_NAME}"
		["source_path"]="${HOST_SOURCE_PATH}"
		["target_host"]="${HOSTNAME}"
		["ssh_cmd"]="$(proj_client_deploy_define_env_vars_string  ${runtime_args[build_image]} ${runtime_args[rem_vol]}) bash ${HOST_SCRIPTS_PATH}/host_deploy_application.sh"
		["compose_path"]="${COMPOSE_PATH}"
		["image_spec_path"]="${IMAGE_SPEC_PATH}"
		["build_context"]="${BUILD_CONTEXT}"
		["rem_vol"]="${runtime_args[rem_vol]}"
	)

	# check where the container is being deployed
	if [[ "${runtime_args[deploy_dest]}" == "local" ]]; then
		# this is a local deployment
		
		# declare the environment variables for the local deployment
		proj_client_export_env_vars "${runtime_args[env_name]}" "${runtime_args[build_image]}"
		
		# export the CONTAINER_APP_PORT variable so it can be used during the container deployment
		export "CONTAINER_APP_PORT"
		
		# this is a container deployment to a local endpoint, specify the run_mode function argument
		deploy_args[run_mode]="${runtime_args[run_mode]}"
	fi
	
	# deploy the container for the specified scenario
	cad_client_deploy_container "deploy_args"

	echo "the container deployment script has finished executing"
}