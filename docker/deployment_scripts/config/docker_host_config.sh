#! /bin/bash

# docker user account
DOCKER_ACCOUNT_NAME="docker-user"

# define the project folder name
SIA_PROJECT_FOLDER="staff-info-app"

# define the docker source directory (parent folder used to clone the SIA repo and prepare the docker preparation folder)
DOCKER_SOURCE_DIR="/tmp/$SIA_PROJECT_FOLDER"

# define the PHP shared library git url
PHP_LIB_GIT_URL="git@picgitlab.nmfs.local:centralized-data-tools/php-shared-library.git"


DOCKER_TARGET_DIR="/home/$DOCKER_ACCOUNT_NAME/containers/staff-directory"

DOCKER_GIT_URL="git@picgitlab.nmfs.local:omi-apps/staff-info-app.git"


