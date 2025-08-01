#!/bin/bash

# this function parses the standard configuration data that is provided to bash scripts via stdin and stores them in the corresponding bash variables
# this function accepts no parameters
function parse_config_data()
{
	echo "running parse_config_data()"


	while IFS='=' read -r key value; do
		case "$key" in
			DB_USERNAME) DB_USERNAME="$value";;
			DB_PASSWORD) DB_PASSWORD="$value";;
			*)
				# output warning message to stderr
				echo "Warning: unknown configuration key '$key' ignored" >&2
				;;
		esac
	done
	
	echo "The value of DB_USERNAME is: $DB_USERNAME"

}

# this function encodes the standard configuration data stored in bash variables so it can be passed to bash scripts via stdin
# this function accepts no parameters
function encode_config_data ()
{
	echo "running encode_config_data()"
	
	printf 'DB_USERNAME=%s\n' "$DB_USERNAME"
	printf 'DB_PASSWORD=%s\n' "$DB_PASSWORD"
}


# function to unset bash variables specified by STDIN:
function unset_config_variables()
{
	echo "running unset_config_variables()"
	unset DB_USERNAME, DB_PASSWORD
}
