#!/bin/bash

#-----------------------------------------------------------------------------
# include_host_resources.sh:
# this file loads all of the reusable bash files that are used in the host
# container deployment scripts (intended for remote container host scenarios)
#-----------------------------------------------------------------------------

# determine current folder path (container_application_deployment/deployment_scripts/host_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include the CAD host functions
source "${CURR_DIR}/../../../../modules/CAD/src/includes/load_CAD_host_resources.sh"

# include the custom container configuration variables
source "${CURR_DIR}/../../config/initial_container_config.sh"
source "${CURR_DIR}/../../config/custom_container_config.sh"
source "${CURR_DIR}/../../config/container_config.sh"

# include the project-specific host functions
source "${CURR_DIR}/../functions/custom_host_functions.sh"
source "${CURR_DIR}/../functions/host_functions.sh"