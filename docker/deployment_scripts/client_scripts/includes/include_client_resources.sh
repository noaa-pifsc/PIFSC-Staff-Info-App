#!/bin/bash

#-----------------------------------------------------------------------------
# include_client_resources.sh:
# this file loads all of the reusable bash files that are used in the client 
# docker deployment scripts (intended for remote docker host scenarios)
#-----------------------------------------------------------------------------

# include the shared functions
source ../../../modules/CDS/src/reusable_functions/shared_functions.sh

# include the client functions
source ../../../modules/CDS/src/reusable_functions/client_functions.sh
source ./functions/custom_client_functions.sh

# include the docker host configuration variables
source ../config/docker_config.sh
