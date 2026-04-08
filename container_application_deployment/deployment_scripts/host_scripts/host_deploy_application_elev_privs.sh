#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_application_elev_privs.sh:
# this host script runs as the $PRIV_USER to (optionally) build and run 
# the container application
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# deploy the container in stack mode
proj_host_deploy_container_elev_privs