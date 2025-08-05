#! /bin/bash

# docker user account
DOCKER_ACCOUNT_NAME="docker-user"

# define the project folder name
SIA_PROJECT_FOLDER="staff-info-app"

# shared library folder name
# SHARED_LIBRARY_FOLDER="php-shared-library"

# define the docker source directory (parent folder used to clone the SIA repo and prepare the docker preparation folder)
DOCKER_SOURCE_DIR="/tmp/$SIA_PROJECT_FOLDER"

# define the project folder path where the prepared project files will be located (next to the project repository in the docker_projects folder)
# DOCKER_REPO_FOLDER_PATH="$DOCKER_SOURCE_DIR/repository"
# DOCKER_PREP_FOLDER_PATH="$DOCKER_SOURCE_DIR/docker"


# define the PHP shared library git url
PHP_LIB_GIT_URL="--branch branch_v1.16 git@picgitlab.nmfs.local:centralized-data-tools/php-shared-library.git"


DOCKER_TARGET_DIR="/home/$DOCKER_ACCOUNT_NAME/containers/staff-directory"

DOCKER_GIT_URL="--branch branch_v1.2_code_reorg git@picgitlab.nmfs.local:omi-apps/staff-info-app.git"


