#!/bin/bash

#-----------------------------------------------------------------------------
# deploy_container_to_local.sh:
# this client script deploys a container to a local docker desktop instance
#-----------------------------------------------------------------------------

# force script to exit immediately when an error is encountered
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in local client scripts
source ./includes/include_local_client_resources.sh

# initialize the deployment script
initialize_deployment_script "$0"

# notify the user which script is being run
echo "******************************************************************************"
echo "********* Executing Staff Info App container local deployment script *********"
echo "******************************************************************************"
echo "*Note: This script will deploy the current version of the Staff Info App to a local docker development environment for development or testing purposes to ensure the project will run in a docker swarm with docker secrets"
echo ""

# deploy the container locally based on the arguments specified by the user ($1 is the environment: dev, test, prod), ($2 == mount is for local development with mounted local folders, $1 == stack is for local testing with docker stack and docker secrets) 
deploy_container_locally "${1:-}" "${2:-}"
