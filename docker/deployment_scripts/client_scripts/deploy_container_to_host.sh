#!/bin/bash

#-----------------------------------------------------------------------------
# deploy_container_to_host.sh:
# this client script deploys a container to a remote docker host
#-----------------------------------------------------------------------------


# force script to exit immediately when an error is encountered
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in client scripts
source ./includes/include_client_resources.sh

# initialize the deployment script
initialize_deployment_script "$0"

# notify the user which script is being run
echo "************************************************************************"
echo "********* Executing Staff Info App container deployment script *********"
echo "************************************************************************"
echo "*Note: This script will deploy the current version of the Staff Info App to the specified docker host"
echo ""

# deploy the container locally based on the arguments specified by the user ($1 is the environment: dev, test, prod)
prepare_execute_deployment_script "${1:-}"
