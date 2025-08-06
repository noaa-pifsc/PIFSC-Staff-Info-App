#!/bin/bash

# force script to exit immediately when an error is encountered
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include shell script function definitions
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh
source ./functions/client_functions.sh
source ./functions/local_dev_test_client_functions.sh

# include shell script configuration information
source ../config/docker_host_config.sh

# initialize the deployment script
initialize_deployment_script "$0"

# notify the user which script is being run
echo "******************************************************************************"
echo "********* Executing Staff Info App container local deployment script *********"
echo "******************************************************************************"
echo "*Note: This script will deploy the current version of the Staff Info App to a local docker development environment for development or testing purposes to ensure the project will run in a docker swarm with docker secrets"
echo ""

# deploy the container locally based on the arguments specified by the user ($1 == 1 is for local development with mounted local folders, $1 == 0 is for local testing with docker stack and docker secrets)
deploy_container_locally "$1" "$2"
