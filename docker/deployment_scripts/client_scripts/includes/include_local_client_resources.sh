#!/bin/bash

#-----------------------------------------------------------------------------
# include_local_client_resources.sh:
# this file loads all of the reusable bash files that are used in the local 
# client docker deployment scripts (intended for development/testing purposes 
# using docker desktop)
#-----------------------------------------------------------------------------

# include the shared functions
source ../../../modules/CDS/src/reusable_functions/shared_functions.sh

# include the client functions
source ./functions/custom_local_client_functions.sh
source ../../../modules/CDS/src/reusable_functions/local_client_functions.sh
source ../../../modules/CDS/src/reusable_functions/client_functions.sh

# include the docker host configuration variables
source ../config/docker_config.sh
