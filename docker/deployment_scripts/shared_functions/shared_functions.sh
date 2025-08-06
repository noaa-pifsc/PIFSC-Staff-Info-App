#!/bin/bash

# function that converts line endings for all .sh and .env files in the path parameter using dos2unix
# this function accepts one parameter: the directory path that will have files updated to convert the line endings
# Usage:
# convert_dos2unix "$1"
function convert_dos2unix ()
{
	# save the parameter value in a local variable
	local passed_path_value="$1"

#	echo "running convert_dos2unix($1)"

	# find all .sh files in the $passed_path_value and execute dos2unix on them
	find "$passed_path_value" -type f \( -name "*.sh" \) -exec dos2unix {} +

}

# function that parses the file name from the script path provided in $1, saves the file name in $CURRENT_SCRIPT_NAME
# Usage:
# get_script_name_from_path "$1"
function get_script_name_from_path ()
{
# 	echo "running get_script_name_from_path ($1)"

	# parse the file name and assign to CURRENT_SCRIPT_NAME
	CURRENT_SCRIPT_NAME=$(basename "$1")
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
