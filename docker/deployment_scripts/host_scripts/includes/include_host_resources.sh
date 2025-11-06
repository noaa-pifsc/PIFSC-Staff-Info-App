#!/bin/bash

#-----------------------------------------------------------------------------
# include_host_resources.sh:
# this file loads all of the reusable bash files that are used in the host
# docker deployment scripts (intended for remote docker host scenarios)
#-----------------------------------------------------------------------------

# include the shared functions
source ../reusable_functions/shared_functions.sh

# include the host functions
source ../reusable_functions/host_functions.sh
source ./functions/custom_host_functions.sh

# include the docker host configuration variables
source ../config/docker_config.sh
