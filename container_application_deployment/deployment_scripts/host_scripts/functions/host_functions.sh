#!/bin/bash

# function to execute the container stack deployment on the docker host using a privileged account
# This function accepts no parameters: 
function proj_host_deploy_container_elev_privs()
{
	# required bash variable validation
	if ! cds_shared_validate_required_vars "HOST_SOURCE_PATH" "IMAGE_NAME" "STACK_NAME" "SECRET_MAPPING_VAR_NAME" "NETWORK_NAME" "BUILD_IMAGE" "COMPOSE_PATH" "IMAGE_SPEC_PATH" "BUILD_CONTEXT" "HOST_TARGET_PATH"; then 
        echo "Error: proj_host_deploy_container() function argument validation failed" >&2
        return 1
    fi

	# prepare the container host target directory by transferring the necessary source files
	proj_host_prepare_container_target_dir "${HOST_SOURCE_PATH}" "${HOST_TARGET_PATH}" 

	# declare the function arguments
	local -A host_deploy_stack_args=(
			["image_name"]="${IMAGE_NAME}"
			["stack_name"]="${STACK_NAME}"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["network_name"]="${NETWORK_NAME}"
			["deploy_dest"]="server"
			["build_image"]="${BUILD_IMAGE}"
			["compose_path"]="${COMPOSE_PATH}"
			["image_spec_path"]="${IMAGE_SPEC_PATH}"
			["build_context"]="${BUILD_CONTEXT}"
		)

	# execute the secret definitions and the container build/run process on the target folder using a privileged account
	cds_shared_deploy_container_stack "host_deploy_stack_args"
}

# function to initiate the container deployment process on the container host using an unprivileged account
# This function accepts no parameters: 
function proj_host_deploy_container()
{
	# required bash variable validation
	if ! cds_shared_validate_required_vars "PRIV_USER" "HOST_SOURCE_PATH" "SECRET_DATA_VAR_NAME" "HOST_SCRIPTS_PATH" "SECRET_MAPPING_VAR_NAME" "BUILD_IMAGE"; then 
        echo "Error: proj_host_deploy_container() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments
	local -A host_deploy_stack_args=(
			["target_user"]="${PRIV_USER}"
			["source_path"]="${HOST_SOURCE_PATH}"
			["secret_var"]="${SECRET_DATA_VAR_NAME}"
			["deploy_script_path"]="${HOST_SCRIPTS_PATH}/host_deploy_application_elev_privs.sh"
			["env_block"]="$(proj_host_define_env_vars_block)"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["process_secrets"]="${BUILD_IMAGE}"
		)
		
	#initiate the build/run process for the container using a privileged account on the host
	cds_host_deploy_container "host_deploy_stack_args"
}