#!/bin/bash

#-----------------------------------------------------------------------------
# restart_container_on_host.sh:
# this client script restarts a container on a remote docker host
#-----------------------------------------------------------------------------

# force script to exit immediately when an error is encountered
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in client scripts for use in the remote docker host
source ./includes/include_client_resources.sh

# initialize the deployment script
initialize_deployment_script "$0"

# notify the user which script is being run
echo "***********************************************************************************"
echo "********* Executing PIFSC Resource Inventory App container restart script *********"
echo "***********************************************************************************"
echo "*Note: This script will restart the PIFSC Resource Inventory app on the specified docker host"
echo ""

# restart the container based on the arguments specified by the user ($1 is the environment: dev, test, prod), ($2 is an argument to determine if the image is rebuilt [yes] or not [no])
prepare_execute_restart_script "${1:-}" "${2:-}"
