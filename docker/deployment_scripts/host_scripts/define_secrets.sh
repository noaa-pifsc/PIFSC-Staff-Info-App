#!/bin/bash

#-----------------------------------------------------------------------------
# define_secrets.sh:
# this host script runs a script as the $DOCKER_ACCOUNT_NAME to define the 
# docker secrets that are used by the docker container by executing 
# docker_define_secrets.sh
#-----------------------------------------------------------------------------

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in host scripts
source ./includes/include_host_resources.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# read the key/value pairs from STDIN and store them in bash variables
parse_config_data

# encode the configuration variable data:
CONFIG_DATA=$(encode_config_data)

# unset bash variables specified by STDIN
unset_config_variables

# define the absolute path to the deployment script that will run as $DOCKER_ACCOUNT_NAME.
SCRIPT_PATH="${DOCKER_SOURCE_DIR}/docker/deployment_scripts/host_scripts/docker_define_secrets.sh"

# Run the deployment script and pass in the key/value pairs stored in $CONFIG_DATA to stdin.
# The outer heredoc (<<EOF) sends commands to 'sudo su - $DOCKER_ACCOUNT_NAME'.
# This command chain works passwordless due to specific sudoers configuration:
# 1. 'sudo su - docker-user': Allowed via 'NOPASSWD: /bin/su - docker-user' in sudoers.
# 2. Bypasses 'Defaults requiretty': This specific nested heredoc structure
#    was designed to bypass sudo's 'requiretty' setting in non-interactive contexts,
#    which would otherwise demand a terminal and cause the script to fail.
# The inner heredoc (cat <<'CREDEND') passes CONFIG_DATA literally to the target script.
# Single quotes around 'CREDEND' (e.g., 'CREDEND') are critical. They prevent Bash
# from performing variable expansion, command substitution, or backslash escaping
# on the $CONFIG_DATA content, ensuring that special characters (like literal '$')
# are preserved exactly as defined.
sudo su - ${DOCKER_ACCOUNT_NAME} <<EOF
cat <<'CREDEND' | bash "$SCRIPT_PATH"
$CONFIG_DATA
CREDEND
EOF

# unset the CONFIG_DATA variable
unset CONFIG_DATA

echo "$CURRENT_SCRIPT_NAME has finished running"
