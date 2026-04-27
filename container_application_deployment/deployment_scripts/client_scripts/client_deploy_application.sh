#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# client_deploy_application.sh:
# this client script deploys a container to a remote container server or locally
#-----------------------------------------------------------------------------

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# main function that executes the container deployment based on the arguments specified by the user 
# $0: full path of the script that was executed directly
# $1: (optional) the environment name (dev, test, prod)
# $2: (optional) deployment destination (local, server)
# $3: (optional) build_image (yes = the container image is built and then run, no = the container is restarted using the existing container image)
# $4: (optional) remove volume flag - remove the volumes associated with the docker stack name (yes) or retain them (no). This defaults to "no"
# $5: (optional) container run mode (mount = mounting source code directories, stack = deploying as container stack with secrets), when deplyment destination = server this argument is ignored
function main ()
{
	# notify the user which script is being run
	echo "*********************************************************************"
	echo "********* Executing container application deployment script *********"
	echo "*********************************************************************"
	echo "*Note: This script will deploy the container application to the specified destination"
	echo ""

	# declare the function arguments
	local -A func_args=(
			["env_name"]="${1:-}"
			["deploy_dest"]="${2:-}"
			["build_image"]="${3:-}"
			["rem_vol"]="${4:-no}"
			["run_mode"]="${5:-}"
		)

	proj_client_deploy_container "func_args"
}

# execute the main function with all arguments from this calling script:
main "$@"