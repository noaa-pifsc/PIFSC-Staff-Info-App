#!/bin/bash

#-----------------------------------------------------------------------------
# build_run_container.sh:
# this host script runs a script as the $DOCKER_ACCOUNT_NAME to build the 
# docker image and run the container on the docker host by executing 
# docker_build_run_container.sh
#-----------------------------------------------------------------------------

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# load all function definition files used in host scripts
source ./includes/include_host_resources.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# define the absolute path to the deployment script that will run as $DOCKER_ACCOUNT_NAME.
DEPLOY_SCRIPT="${DOCKER_SOURCE_DIR}/docker/deployment_scripts/host_scripts/docker_build_run_container.sh"

# run the docker deployment script as $DOCKER_ACCOUNT_NAME
# define the DB_HOST and DB_SERVICE_NAME environment variables
sudo su - "${DOCKER_ACCOUNT_NAME}" <<EOF
#!/bin/bash
# set the environment variable values for the DB host
export DB_HOST="$DB_HOST"
export DB_SERVICE_NAME="$DB_SERVICE_NAME"
# run the deployment script
bash ${DEPLOY_SCRIPT}
EOF

# clean up project folders/files that were used to build and run the docker container
rm -rf "$DOCKER_SOURCE_DIR"

# echo "$CURRENT_SCRIPT_NAME has finished running"
