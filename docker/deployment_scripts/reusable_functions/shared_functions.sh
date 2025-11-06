#!/bin/bash

#-----------------------------------------------------------------------------
# shared_functions.sh:
# this file defines reusable functions used in client and host scripts 
# for docker deployments (in both local docker desktop and remote docker 
# host scenarios)
#-----------------------------------------------------------------------------

# function that converts line endings for all .sh and .env files in the path parameter using dos2unix
# this function accepts one parameter: the directory path that will have files updated to convert the line endings
# Usage:
# convert_dos2unix "$1"
function convert_dos2unix ()
{
	# save the parameter value in a local variable
	local passed_path_value="$1"

	# find all .sh files in the $passed_path_value and execute dos2unix on them
	find "$passed_path_value" -type f \( -name "*.sh" \) -exec dos2unix {} +
}

# function that parses the file name from the script path provided in $1, saves the file name in $CURRENT_SCRIPT_NAME
# the function accepts one parameter: the full script path
# Usage: get_script_name_from_path "$1"
function get_script_name_from_path ()
{
	# parse the file name and assign to CURRENT_SCRIPT_NAME
	CURRENT_SCRIPT_NAME=$(basename "$1")
}

# function that creates or updates a docker secret from a given value and handles special characters safely
# this function accepts two parameters: secret_name is the name of the docker secret, secret_value is the value of the docker secret
# returns: Nonzero on usage error or internal failure.
# usage: create_secret "DB_USERNAME" "DB_APP_USERNAME" 
function create_secret() {
	local secret_name="$1"
	local secret_value="$2"

	# check if either parameter is blank
	if [ -z "$secret_name" ] || [ -z "$secret_value" ]; then
		echo "Error: Both secret_name and secret_value are required." >&2
		return 1
	fi

	# Check if the secret already exists. If so, remove it first to update the secret.
	if docker secret ls --format "{{.Name}}" | grep -q "^$secret_name$"; then
#		echo "Secret '$secret_name' already exists. Removing to update..."
		docker secret rm "$secret_name" >/dev/null
	fi

	# The `printf %s` command prints the string without adding a trailing newline and the heredoc prevents any shell expansion.
	printf "%s" "$secret_value" | docker secret create "$secret_name" -

	if [ $? -eq 0 ]; then
		echo "Secret '$secret_name' created successfully."
	else
		echo "Error creating secret '$secret_name'." >&2
		return 1
	fi
}

# function to build and save the image from source code (optionally), and deploy the docker stack
# *Note: the current directory must be the docker directory that contains Dockerfile and docker-compose.yml
# this function accepts 3 parameter (DOCKER_IMAGE_NAME is the name of the docker image [e.g. pifsc/docker-project]), (DOCKER_STACK_NAME is the name of the docker stack), (REBUILD_IMAGE which is expected to be yes or no)
# Usage: build_deploy_docker_stack pifsc/docker-project PRI_stack yes|no
function build_deploy_docker_stack()
{
#	echo "Running build_deploy_docker_stack($1, $2, $3)"
	
	# Check if the REBUILD_IMAGE variable is "yes" 
	if [[ "$3" == "yes" ]]; then
		# build and save the image

		# build the docker container
		docker build -t "$1":latest -f ./Dockerfile .

		# save and reload image to ensure the latest image is being used in docker swarm
		docker save "$1":latest | docker load
	fi

	# Deploy the stack
	docker stack deploy -c docker-compose.yml "$2"
}

# function that removes the docker stack identified by $1
# the function accepts one parameter: the docker stack name 
# usage: remove_docker_stack PIFSC_stack
function remove_docker_stack()
{
	# stop the docker stack if it exists:
	docker stack rm "$1"
}

# function that waits for the docker network name to be removed (specified by $1)
# the function accepts one parameter: the docker network name that will be checked in a loop to determine when it is no longer defined in the docker stack so the corresponding docker container can be redeployed
# Usage: wait_for_docker_network_removal "$DOCKER_NETWORK_NAME"
function wait_for_docker_network_removal ()
{
#	echo "running wait_for_docker_network_removal ($1)"
	
	# loop every 1 second to wait until the specified docker stack's network has been removed, if the deployment begins before the docker stack's network is removed it will throw an error when the "docker stack deploy" command runs:
	while docker network ls --format '{{.Name}}' | grep -q "^$1$"; do
		echo "Waiting for network $1 removal..."
		sleep 1
	done
}

# this function fetches a specific dependency using Git into a specific directory
# the function accepts two parameters: repo_url is the repository url for the given dependency's repository and target_dir is the target directory where the repository is cloned to 
# Usage: fetch_git_dependency "git_url" "clone_path"
function fetch_git_dependency() {
#	echo "running fetch_git_dependency ($1, $2)"
	local repo_url="$1"
	local target_dir="$2"

	git clone "$repo_url" "$target_dir"
}

# this function copies files from a source to a target based on a list of filename expansions
# the function accepts at least 3 parameters: the source_dir that defines the source directory the specified directories will be copied from, the target_dir that defines the target directory the specified directories will be copied to, and then one or more string values that correspond to the filename_expansion values (e.g. *.inc, oracle*.php) that will be copied.
# Usage: copy_files_by_filename_expansion "source_dir" "target_dir" "*.php" "*.inc"
function copy_files_by_filename_expansion() {
	local source_dir="$1"
	local target_dir="$2"
	shift 2 # Remove the first two args, the rest are filename_expansions
	
	for filename_expansion in "$@"; do
#		echo "Copying $filename_expansion files from $source_dir to $target_dir"
		cp -r "$source_dir"/${filename_expansion} "$target_dir"
	done
}

# Copies a list of sub-directories from a source to a target
# the function accepts at least 3 parameters: the source_dir that defines the source directory the specified directories will be copied from, the target_dir that defines the target directory the specified directories will be copied to, and then one or more string values that correspond to the subdirectories that will be copied.
# Usage: copy_asset_directories "source_dir" "target_dir" "css" "js" "img"
function copy_asset_directories() {
#	echo "running copy_asset_directories($1, $2)"
	local source_dir="$1"
	local target_dir="$2"
	shift 2 # The rest are directory names
	
	for dir in "$@"; do
#		echo "Copying $dir/ from $source_dir to $target_dir"
		cp -r "$source_dir/$dir" "$target_dir"
	done
}

# this function parses configuration data passed in to the given script via STDIN in key/value pairs ($key=$value format delimited by newline characters)
# this function accepts one parameter: the name of an associative array that defines array values that correspond to the $key values in the STDIN string. Only $key values defined in the associative array values are used, others are ignored with a warning.  The corresponding bash variables with the name $key and the value of $value are created for each matching key/value pair in STDIN
# Returns: 0 on success. Nonzero on usage error or internal failure
# Usage: generic_parse_config_data SECRET_MAPPING_ARR
function generic_parse_config_data() {
#	echo "running generic_parse_config_data()" >&2

	# Require the name of an associative array, for example SECRET_MAPPING_ARR.
	if [[ -z "${1-}" ]]; then
		echo "ERROR: generic_parse_config_data requires map name as arg 1." >&2
		return 1
	fi

	local map_name="$1"

	# Verify the variable exists and is an associative array.
	# declare -p outputs a declaration string that starts with 'declare -A' for maps.
	if ! declare -p "$map_name" >/dev/null 2>&1; then
		echo "ERROR: Variable '$map_name' is not defined in scope." >&2
		return 1
	fi
	local decl
	decl="$(declare -p "$map_name" 2>/dev/null)"
	if [[ "$decl" != declare\ -A* ]]; then
		echo "ERROR: '$map_name' must be an associative array." >&2
		return 1
	fi

	# Create a nameref to the provided associative array so we can access it directly.
	local -n assoc_ref="$map_name"

	# Build a fast membership map of allowed keys.
	# The allowlist consists of the VALUES of the mapping, which must be valid Bash identifiers.
	declare -A key_map=()
#	echo "Building allowlist from values of associative map '$map_name' (${#assoc_ref[@]} entries):" >&2

	local map_key varname
	for map_key in "${!assoc_ref[@]}"; do
		varname="${assoc_ref[$map_key]}"

		# Validate that the mapping value is a legal Bash variable name.
		# This prevents creating unexpected variables or code injection through names.
		if [[ -z "$varname" || ! "$varname" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
			echo "Warning: Skipping invalid variable name in $map_name for key '$(echo -n "$map_key" | cat -v)': '$(echo -n "$varname" | cat -v)'." >&2
			continue
		fi

		key_map["$varname"]=1
#		echo "  - Expecting key: $varname" >&2
	done

	# Read STDIN line by line.
	# IFS= read -r preserves leading and trailing spaces and backslashes.
	# The '|| [[ -n "$line" ]]' part ensures we process the last line even if it lacks a trailing newline.
	local line key value
	while IFS= read -r line || [[ -n "$line" ]]; do
		# Normalize CRLF by trimming a single trailing carriage return, if present.
		[[ $line == *$'\r' ]] && line=${line%$'\r'}

		# Skip empty lines quietly.
		[[ -z "$line" ]] && continue

		# Each line must contain an '='.
		# Use cat -v to make hidden control characters visible in the warning message.
		if [[ "$line" != *"="* ]]; then
			echo "Warning: Skipping invalid line format in STDIN: '$(echo -n "$line" | cat -v)'" >&2
			continue
		fi

		# Split on the first '=' only.
		# Left side becomes KEY. Right side becomes VALUE and may include '='.
		key=${line%%=*}
		value=${line#*=}

		# Trim parsed values for any stray trailing carriage returns after the split.
		key=${key%$'\r'}
		value=${value%$'\r'}

		# For debugging, print the key only
#		echo "DEBUG: Parsed KEY='$(echo -n "$key" | cat -v)'" >&2

		# Enforce allowlist. The '+_' trick distinguishes set vs unset entries
		# and allows empty values if the key is allowed.
		if [[ -n ${key_map[$key]+_} ]]; then
			# Assign variable value into the current shell scope. 
			printf -v "$key" "%s" "$value"

			# Optional info level log. This confirms assignment but does not leak data.
#			echo "Set $key" >&2
		else
			echo "Warning: Unknown configuration key '$(echo -n "$key" | cat -v)' ignored." >&2
		fi
	done

	# At this point all allowed KEYs from STDIN are available as plain Bash variables
	# in the current shell. They can be consumed by other functions, such as
	# generic_set_docker_secrets SECRET_MAPPING_ARR.
	return 0
}

# function that unsets all bash variables that are defined by the corresponding associative array's values
# this function accepts one parameter: the name of an associative array that defines array values that correspond to the bash variables that are unset. 
# Returns: nonzero on usage error or internal failure.
# Usage: generic_unset_config_variables SECRET_MAPPING_ARR
function generic_unset_config_variables() {
	# Input Validation: Check if the required argument is provided.
	if [[ -z "$1" ]]; then
		echo "ERROR: generic_unset_config_variables requires an array name as argument 1." >&2
		return 1
	fi

	# -n creates a nameref: 'var_names' becomes an alias for the array name passed.
	local -n var_names=$1
	
#	echo "Unset the bash variable names: ${var_names[@]}"
	
	# 'unset' is called with the expanded list of variable names.
	# The double quotes around the expansion prevent globbing and word splitting.
	unset "${var_names[@]}"
}

# function to encode key=value data in a string formatted for specifying to another script via STDIN. The function generates a newline-delimited string of key/value pairs in $key=$value format based on the corresponding variable values.
# this function accepts one parameter: the name of an associative array that defines array values that correspond to bash variable names.   
# Returns: nonzero on usage error or internal failure.
# Usage: generic_encode_config_data SECRET_MAPPING_ARR
function generic_encode_config_data() {
	
	# Input Validation: Check if the required argument is provided.
	if [[ -z "$1" ]]; then
		echo "ERROR: generic_encode_config_data requires an array name as argument 1." >&2
		return 1
	fi
	
	# -n creates a nameref: 'var_names' becomes an alias for the array name passed.
	local -n var_names=$1
	local var_name
	
	# Loop through the list of variable names.
	for var_name in "${var_names[@]}"; do
		# -n creates a nameref: 'var_value_ref' becomes an alias for the actual variable
		# whose name is stored in $var_name. This is Bash indirection.
		local -n var_value_ref=$var_name
		
		# Robustness Check: Validate that the variable is set and has a non-empty value.
		# ${variable+x} tests for existence (unset). If the variable is not set at all, it's a ERROR.
		if [[ -z "${var_value_ref+x}" ]]; then
			echo "ERROR: Configuration variable '$var_name' is not set. Cannot encode." >&2
			return 1 # Halts the script with a failure code.
		fi
		
		# Use printf to safely output the key=value pair to STDOUT to avoid issues with special characters and ensures no trailing newline.
		printf '%s=%s\n' "$var_name" "${var_value_ref}"
	done
}

# function to create docker secrets based on a mapping of secret names to bash variables.
# this function iterates over an associative array that maps the required docker secret name to the corresponding bash variable containing the secret value.
# this function accepts one parameter: the name of an associative array that defines array elements and values that correspond to the secret names and values respectively.  
# Returns: nonzero on usage error or internal failure.
# Usage: generic_encode_config_data SECRET_MAPPING_ARR
function generic_set_docker_secrets() {

#	echo "running generic_set_docker_secrets()"
	# Input Validation: Check if the required argument is provided.
	if [[ -z "$1" ]]; then
		echo "ERROR: generic_set_docker_secrets requires a map name as argument 1." >&2
		return 1
	fi
	
	# -n creates a nameref: 'secret_map' becomes an alias for the associative array name passed.
	local -n secret_map=$1
	local secret_name bash_var_name secret_value

	# Iterate over the keys (Docker Secret Names) in the associative array
	for secret_name in "${!secret_map[@]}"; do
		# Get the name of the source bash variable (e.g., DB_USERNAME)
		bash_var_name="${secret_map[$secret_name]}"
		
		# Use a nameref trick to get the VALUE of the source variable.
		# 'source_var_value_ref' is now an alias for the variable named by $bash_var_name.
		local -n source_var_value_ref="$bash_var_name"
		secret_value="${source_var_value_ref}"

		# Robustness Check: Validate that the source variable is actually set.
		# This checks for undefined or empty variables before attempting to create a secret.
		# ${variable+x} tests for existence (unset), preventing the script from proceeding with empty data.
		if [[ -z "${secret_value+x}" ]]; then
			echo "ERROR: Bash variable '$bash_var_name' for secret '$secret_name' is not set. Cannot create secret." >&2
			return 1
		fi

#		echo "the value of secret name is: $secret_name"

		# Call the create_secret function
		# This function (defined elsewhere) handles piping the value to 'docker secret create'.
		# We rely on 'create_secret' to handle cleanup of existing secrets and failure reporting.
		create_secret "$secret_name" "$secret_value"

		# Check Exit Code Propagation
		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to create Docker secret '$secret_name'. See 'create_secret' output above." >&2
			return 1
		fi
		
#		echo "Successfully set Docker secret: $secret_name"
	done
}


# this function parses the standard configuration data that is provided to bash scripts via stdin and stores them in the corresponding bash variables based on the SECRET_MAPPING_ARR array values
# this function accepts no parameters
function parse_config_data()
{
	# parse the configuration variable data and declare the key/value pairs as bash variables based on the SECRET_MAPPING_ARR array values defined in docker_config.sh:
	generic_parse_config_data SECRET_MAPPING_ARR
}

# this function encodes the standard configuration data stored in bash variables so it can be passed to bash scripts via stdin based on the SECRET_MAPPING_ARR array values
# this function accepts no parameters
function encode_config_data ()
{
	# encode all configuration variables based on the SECRET_MAPPING_ARR array values defined in docker_config.sh
	generic_encode_config_data SECRET_MAPPING_ARR
}

# function to unset bash variables specified by STDIN based on the SECRET_MAPPING_ARR array values:
function unset_config_variables()
{
	# unset all configuration variables based on the SECRET_MAPPING_ARR array values defined in docker_config.sh
	generic_unset_config_variables SECRET_MAPPING_ARR
}

# function to set the database secrets based on the SECRET_MAPPING_ARR associative array (containing secret names, variable names) and the corresponding variable values
function set_db_secrets() {

    # set the database secrets based on the SECRET_MAPPING_ARR array elements and values defined in docker_config.sh
    generic_set_docker_secrets SECRET_MAPPING_ARR
}
