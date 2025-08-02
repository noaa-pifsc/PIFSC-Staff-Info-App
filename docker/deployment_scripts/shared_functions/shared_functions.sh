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
