#!/bin/bash

# function to execute the container stack deployment on the docker host
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# container_target_path: the container target directory that contains the Dockerfile, docker-compose.yml files
# container_image_name: the container image name
# container_stack_name: the container stack name
# secret_mapping_var_name: name of an associative array that maps the secret values passed to bash commands via STDIN
# container_network_name: container network name
# container_deploy_dest: the deployment destination (local or server)
# container_build_image: (yes = the container image is built and then run, no = the container is restarted using the existing container image)
# calling_script_path: the full path of the calling script
function host_deploy_container_elev_privs()
{
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: host_deploy_container_elev_privs() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi
	
	# input validation
	if ! validate_required_array_vals "${arg_array}" "container_target_path" "container_image_name" "container_stack_name" "secret_mapping_var_name" "container_network_name" "container_build_image" "calling_script_path"; then 
        echo "ERROR: host_deploy_container_elev_privs() function argument validation failed" >&2
        return 1
    fi
	
	# initialize the container environment variables
	initialize_container_env_var "$(get_array_val "${arg_array}" "calling_script_path")"

	# prepare the container host target directory by transferring the necessary source files
	host_prepare_container_target_dir

	# declare the function arguments
	local -A LOCAL_FUNC_ARGS=(
			["container_target_path"]="$(get_array_val "${arg_array}" "container_target_path")"
			["container_image_name"]="$(get_array_val "${arg_array}" "container_image_name")"
			["container_stack_name"]="$(get_array_val "${arg_array}" "container_stack_name")"
			["secret_mapping_var_name"]="$(get_array_val "${arg_array}" "secret_mapping_var_name")"
			["container_network_name"]="$(get_array_val "${arg_array}" "container_network_name")"
			["container_deploy_dest"]="server"
			["container_build_image"]="$(get_array_val "${arg_array}" "container_build_image")"
		)

	# execute the secret definitions and the container build/run process on the target folder using a privileged account
	deploy_container_stack "LOCAL_FUNC_ARGS"
}