#!/bin/bash

# force script to exit immediately when an error is encountered
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include shell script function definitions
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh
source ./functions/client_functions.sh
source ./functions/host_functions.sh
source ./functions/custom_host_functions.sh

# initialize the deployment script
initialize_deployment_script "$0"

# notify the user which script is being run
echo "******************************************************************************"
echo "********* Executing Staff Info App container local deployment script *********"
echo "******************************************************************************"
echo "*Note: This script will deploy the current version of the Staff Info App to a local docker development environment"
echo ""


# save/prompt for environment name and SSH username
set_env_var "$1" 

# clone the project dependencies into the current working copy where the script was executed from:
git clone $PHP_LIB_GIT_URL ../../docker/src/backend/dependencies/tmp

# copy the required PHP shared library files into the dependencies directory
cp -r ../../docker/src/backend/dependencies/tmp/oracle*.php ../../docker/src/backend/dependencies

# remove the temporary directory
rm -rf ../../docker/src/backend/dependencies/tmp

# build the docker container
docker build -t pifsc/staff-info-app:latest -f ./Dockerfile .

# save and reload image to ensure the latest image is being used in docker swarm
docker save pifsc/staff-info-app:latest | docker load

# Deploy the stack
docker stack deploy -c docker-compose.local.dev.yml SIA_stack



