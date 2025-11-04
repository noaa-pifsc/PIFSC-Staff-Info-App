#!/bin/bash

#-----------------------------------------------------------------------------
# local_client_functions.sh:
# this file defines reusable client functions that are used in local client 
# docker deployment scripts (intended for development/testing purposes 
# using docker desktop)
#-----------------------------------------------------------------------------

# this function exports a series of bash variables as environment variables so they can be used by the docker compose .yml file in the local client deployment mount scenario that would otherwise be defined as docker secrets in remote docker host deployments.
# this function uses the values from an associative array name specified by "$1" to generate and execute the corresponding "export" statements
# Returns: 0 on success. Nonzero on usage error or internal failure.
export_vars_from_mapping() {
	# Verify required argument is present.
	if [[ -z "${1-}" ]]; then
		echo "ERROR: export_vars_from_mapping requires MAP_NAME as arg 1." >&2
		return 1
	fi
	local map_name="$1"

	# Type and existence check for the provided variable name.
	# 'declare -p NAME' prints the declaration for NAME and exits nonzero if undefined.
	if ! declare -p "$map_name" >/dev/null 2>&1; then
		echo "ERROR: Variable '$map_name' is not defined in scope." >&2
		return 1
	fi

	# Capture the declaration text so we can verify it is an associative array.
	# For an associative array, Bash prints a header like: 'declare -A NAME=...'
	local decl
	decl="$(declare -p "$map_name" 2>/dev/null)"
	if [[ "$decl" != declare\ -A* ]]; then
		echo "ERROR: '$map_name' must be an associative array." >&2
		return 1
	fi

	# Create a nameref 'assoc_ref' that refers to the array named by $map_name.
	local -n assoc_ref="$map_name"

	local v
	# Iterate over VALUES of the map, which are the Bash variable names to export.
	for v in "${assoc_ref[@]}"; do
		# Validate that the value is a legal Bash identifier before exporting.
		# This prevents bad or crafted names from affecting the environment.
		if [[ -z "$v" || ! "$v" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
			echo "Warning: Skipping invalid var name '$(echo -n "$v" | cat -v)'" >&2
			continue
		fi

		# Export the name only. Do not print or log the value.
		export "$v"
#		echo "Exported $v" >&2
	done

	return 0
}

# this function builds and deploys a container locally using docker compose and a specified docker compose .yml file.  The function accepts one parameter: the name of the docker compose file
# example usage: build_deploy_container "docker-compose.local.dev.yml"
function build_deploy_container ()
{
	# stop and remove any running container
	docker compose -f "$1" down
	
	# build and run the container
	docker compose -f "$1" up -d  --build
}
