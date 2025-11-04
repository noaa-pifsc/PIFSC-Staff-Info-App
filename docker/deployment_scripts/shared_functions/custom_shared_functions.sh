#!/bin/bash

#-----------------------------------------------------------------------------
# custom_shared_functions.sh:
# this file defines custom functions that are used for this specific docker 
# application in client and host scripts that are used for docker deployments 
# (in both local docker desktop and remote docker host scenarios)
#-----------------------------------------------------------------------------

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