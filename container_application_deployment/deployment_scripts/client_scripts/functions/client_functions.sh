#!/bin/bash

#-----------------------------------------------------------------------------
# client_functions.sh:
# this file defines client functions that are used for this specific 
# container application for container deployments, these do not need to 
# be modified across individual container apps
#-----------------------------------------------------------------------------


# this function prepares and executes the client deployment scripts
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# calling_script_path: the full path of the calling script
# env_name: (optional) the environment name (dev, test, prod)
# deploy_dest: (optional) deployment destination (local, server)
# build_image: (optional) build_image (yes = the container image is built and then run, no = the container is restarted using the existing container image)
# container_run_mode: (optional) container run mode (mount = mounting source code directories, stack = deploying as container stack with secrets) (when deplyment destination = server this argument is ignored)
function client_deploy_container ()
{
	echo "prepare the container source files and deploy the container"
	
	# store the function array argument
	local arg_array="${1}"
	
    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: client_deploy_container() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! validate_required_array_vals "${arg_array}" "calling_script_path"; then 
        echo "ERROR: client_deploy_container() function argument validation failed" >&2
        return 1
    fi

	# validate the bash variable values
	if ! validate_required_vars	"DEPLOYMENT_SCRIPT_LOGS" "CLIENT_CONTAINER_SOURCE_PATH" "SECRET_MAPPING_VAR_NAME" "CONTAINER_COMPOSE_PATH_MOUNT" "CONTAINER_IMAGE_NAME" "CONTAINER_STACK_NAME" "CONTAINER_NETWORK_NAME" "CONTAINER_GIT_URL" "CONFIG_DATA_VAR_NAME" "CONTAINER_HOST_SOURCE_PATH" "CONTAINER_HOST_SCRIPTS_PATH"; then
        echo "ERROR: client_deploy_container() function required bash variable validation failed" >&2
        return 1
	fi
	
	# initialize the deployment script
	initialize_deployment_script "${DEPLOYMENT_SCRIPT_LOGS}" "$(get_array_val "${arg_array}" "calling_script_path")" 
	
	# prepare the client deployment resources
	client_prepare_vars "$(get_array_val "${arg_array}" "calling_script_path")" "$(get_array_val "${arg_array}" "env_name")" "$(get_array_val "${arg_array}" "deploy_dest")"

	# save/prompt for deployment mode
	set_build_image_var "$(get_array_val "${arg_array}" "build_image")"

	if [[ "${DEPLOY_DEST}" == "local" ]]; then
		# this is a local deployment
		
		# save/prompt for container run mode
		set_container_run_mode_var "$(get_array_val "${arg_array}" "container_run_mode")"

		# declare the environment variables for the local deployment
		client_export_env_vars
			
		# change directory into the container folder that contains the Dockerfile and .yml files (/container_application_deployment)
		cd "${CLIENT_CONTAINER_SOURCE_PATH}"

		# check if this is a mounted or stack deployment:
		if [[ "${CONTAINER_RUN_MODE}" == "mount" ]]; then
			# this is a mounted directory deployment

			# declare the function arguments
			local -A LOCAL_FUNC_ARGS=(
					["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
					["container_compose_path_mount"]="${CONTAINER_COMPOSE_PATH_MOUNT}"
					["container_image_name"]="${CONTAINER_IMAGE_NAME}"
					["build_image"]="${BUILD_IMAGE}"
				)

			# deploy the container application locally with folders mounted as volumes for development purposes
			client_deploy_local_container_mount "LOCAL_FUNC_ARGS"
		else
			# use container stack and secrets to test if the code is working for a secure container host deployment

			# declare the function arguments
			local -A LOCAL_FUNC_ARGS=(
					["container_target_path"]="${CLIENT_CONTAINER_SOURCE_PATH}"
					["container_image_name"]="${CONTAINER_IMAGE_NAME}"
					["container_stack_name"]="${CONTAINER_STACK_NAME}"
					["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
					["container_network_name"]="${CONTAINER_NETWORK_NAME}"
					["deploy_dest"]="local"
					["build_image"]="${BUILD_IMAGE}"
				)

			# build and deploy the local container stack
			deploy_container_stack "LOCAL_FUNC_ARGS"
		fi	
	else
		# this is a server deployment

		# declare the function arguments
		local -A LOCAL_FUNC_ARGS=(
				["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
				["container_git_url"]="${CONTAINER_GIT_URL}"
				["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
				["container_host_source_path"]="${CONTAINER_HOST_SOURCE_PATH}"
				["container_hostname"]="${CONTAINER_HOSTNAME}"
				["parse_config_data"]="${BUILD_IMAGE}"
			)
			
		# prepare for the container deployment to the container host
		client_prepare_container_host "LOCAL_FUNC_ARGS"

		# reset array before re-defining elements/values
		LOCAL_FUNC_ARGS=()

		# define the ssh function arguments
		LOCAL_FUNC_ARGS=(
			["container_hostname"]="${CONTAINER_HOSTNAME}"
			["cmd"]="$(client_deploy_define_env_vars_string) bash ${CONTAINER_HOST_SCRIPTS_PATH}/host_deploy_application.sh"
		)

		if [[ "${BUILD_IMAGE}" == "yes" ]]; then
			# this is a deploy container call that includes the build process, specify the stdin data (secrets)
			set_array_val "LOCAL_FUNC_ARGS" "passed_stdin_content" "${!CONFIG_DATA_VAR_NAME}"
		fi

		# execute the deployment script via ssh with corresponding environment variables/stdin configuration data
		exec_remote_cmd "LOCAL_FUNC_ARGS"		
	fi

	echo "the container deployment script has finished executing"
}

# function that initializes the ENV_NAME variable and loads the client secret/configuration files, and process the $CONFIG_DATA_VAR_NAME so it can be passed to a bash script via STDIN
# this function accepts the following parameters: 
# 1: client container source path 
# 2: (optional) the environment name (dev, test, prod)
# 3: (optional) deployment destination (local, server)
function client_prepare_vars ()
{
	local client_container_source_path="${1}"

	# input validation
	if [[ -z "${client_container_source_path}" ]]; then
        echo "ERROR: client_prepare_vars() function requires client_container_source_path as a non-empty argument" >&2
        return 1
	fi

	# set the environment and deployment destination variable values
	set_env_deployment_vars "${2}" "${3}"
	
	# recursively convert the line endings for all .sh files in the root folder of the repository (/)
	convert_dos2unix "${1}"
	
	# load the environment-specific deployment configuration file
	client_load_deploy_config_file
	
	# load the environment-specific client secret file
	client_load_secret_file
}