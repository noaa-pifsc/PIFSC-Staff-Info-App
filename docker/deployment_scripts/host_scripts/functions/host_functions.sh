#!/bin/bash

# function that loads the function parameter to the ENV_NAME variable and loads the environment variables from docker_host.env
# the first parameter is the script path that was executed
# Usage:
# initialize_docker_env_var "$0"
function initialize_docker_env_var ()
{
	# retrieve the current script name that was originally invoked
	get_script_name_from_path "$1"

	echo "running $CURRENT_SCRIPT_NAME"

	# load the configuration variables
	source ../config/docker_host_config.sh
}

# A function to create or update a Docker secret from a given value,
# handling special characters safely.
#
# Arguments:
#   $1: The name of the Docker secret.
#   $2: The value of the Docker secret (can contain special characters).
#
function create_secret() {
    local secret_name="$1"
    local secret_value="$2"

    if [ -z "$secret_name" ] || [ -z "$secret_value" ]; then
        echo "Error: Both secret_name and secret_value are required." >&2
        return 1
    fi

    echo "Processing secret: $secret_name"

    # Check if the secret already exists. If so, remove it to update.
    # This assumes we want to update if the secret exists.
    if docker secret ls --format "{{.Name}}" | grep -q "^$secret_name$"; then
        echo "Secret '$secret_name' already exists. Removing to update..."
        docker secret rm "$secret_name" >/dev/null
    fi

    # Use a here document with a backslashed EOF to pass the value safely.
    # The `printf %s` command prints the string without adding a trailing newline,
    # and the heredoc prevents any shell expansion.
    printf "%s" "$secret_value" | docker secret create "$secret_name" -

    if [ $? -eq 0 ]; then
        echo "Secret '$secret_name' created successfully."
    else
        echo "Error creating secret '$secret_name'." >&2
        return 1
    fi
}
