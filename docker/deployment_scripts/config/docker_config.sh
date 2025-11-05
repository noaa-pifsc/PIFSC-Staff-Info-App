#! /bin/bash

#-----------------------------------------------------------------------------
# docker_config.sh:
# this configuration file defines bash variables to define the behavior of 
# the docker deployment scripts
#-----------------------------------------------------------------------------


# docker user account
DOCKER_ACCOUNT_NAME="docker-user"

# define the project folder name
REPO_NAME="staff-info-app"

# define the docker source directory (parent folder used to clone the SIA repo and prepare the docker preparation folder)
DOCKER_SOURCE_DIR="/tmp/$REPO_NAME"

# define the PHP shared library git url
PHP_LIB_GIT_URL="git@picgitlab.nmfs.local:centralized-data-tools/php-shared-library.git"


DOCKER_TARGET_DIR="/home/$DOCKER_ACCOUNT_NAME/containers/staff-directory"

DOCKER_GIT_URL="--branch Branch_docker_restart git@picgitlab.nmfs.local:omi-apps/staff-info-app.git"


# define the name of the docker stack
DOCKER_STACK_NAME="SIA_stack"

# define the name of the docker network
DOCKER_NETWORK_NAME="${DOCKER_STACK_NAME}_default"

# define the docker image name
DOCKER_IMAGE_NAME="pifsc/$REPO_NAME"

# declare an associative array with the secret name as the array element and the bash variable name as the array value
declare -A SECRET_MAPPING_ARR=(
    # [Docker Secret Name] = "Bash Variable Name"
    ["sia_db_username_secret"]="DB_USERNAME"
    ["sia_db_password_secret"]="DB_PASSWORD"
)
