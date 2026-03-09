#!/bin/bash

#-----------------------------------------------------------------------------
# client_deploy_application.sh:
# this client script deploys a container to a remote container server or locally
#-----------------------------------------------------------------------------

# force script to exit immediately when an error is encountered
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# notify the user which script is being run
echo "*********************************************************************"
echo "********* Executing PIFSC Library Website deployment script *********"
echo "*********************************************************************"
echo "*Note: This script will deploy the PIFSC Library Website to the specified destination"
echo ""

# deploy the container based on the arguments specified by the user 
# $1: (optional) the environment name (dev, test, prod)
# $2: (optional) deployment destination (local, server)
# $3: (optional) container_build_image (yes = the container image is built and then run, no = the container is restarted using the existing container image)
# $4: (optional) container run mode (mount = mounting source code directories, stack = deploying as container stack with secrets), when deplyment destination = server this argument is ignored

# declare the function arguments
declare -A FUNC_ARGS=(
		["calling_script_path"]="${0}"
		["container_env_name"]="${1:-}"
		["container_deploy_dest"]="${2:-}"
		["container_build_image"]="${3:-}"
		["container_run_mode"]="${4:-}"
	)

client_deploy_container "FUNC_ARGS"