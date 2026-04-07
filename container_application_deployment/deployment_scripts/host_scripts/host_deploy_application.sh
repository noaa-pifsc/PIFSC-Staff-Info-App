#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_application.sh:
# this host script runs a script as the $PRIV_USER to (optionally) build the 
# container image and run the container on the container host by executing 
# host_deploy_application_elev_privs.sh
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

#initiate the build/run process for the container using a privileged account on the host
proj_host_deploy_container