#!/bin/bash

# force script to exit immediately when an error is encountered
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include shell script function definitions
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh
source ./functions/client_functions.sh

# initialize the deployment script
initialize_deployment_script "$0"

# notify the user which script is being run
echo "************************************************************************"
echo "********* Executing Staff Info App container deployment script *********"
echo "************************************************************************"
echo "*Note: This script will deploy the current version of the Staff Info App to the specified docker host"
echo ""

# prepare and execute the deployment script
prepare_execute_deployment_script "${1:-}" "${2:-}"
