#!/bin/bash

#-----------------------------------------------------------------------------
# custom_host_functions.sh:
# this file defines custom host functions that are used for this specific 
# docker application for docker deployments (intended for remote docker host 
# scenarios)
#-----------------------------------------------------------------------------

# function to copy the necessary files to deploy the docker application from the specified subdirectory of $DOCKER_SOURCE_DIR to the $DOCKER_TARGET_DIR
# Usage:
# prepare_docker_target_dir
function prepare_docker_target_dir ()
{
	# sync files to docker source directory:
#	echo "Copy the ${DOCKER_SOURCE_DIR}/docker source files to the destination directory: ${DOCKER_TARGET_DIR} so they can used to build/deploy container"

	# remove the files in the docker container target directory
	rm -rf "$DOCKER_TARGET_DIR"/*

	# copy the docker files to the root $DOCKER_TARGET_DIR
	rsync -a "$DOCKER_SOURCE_DIR"/docker/* "$DOCKER_TARGET_DIR"/docker
	rsync -a "$DOCKER_SOURCE_DIR"/modules/* "$DOCKER_TARGET_DIR"/modules

}

# function to prepare the docker preparation folder that will be copied to 
# copy the dependencies from the PHP shared library to the corresponding "dependencies" folder of the $DOCKER_SOURCE_DIR and update the folder permissions so the $DOCKER_ACCOUNT_NAME can build and run the container
function prepare_docker_prep_folder ()
{
	echo "prepare the docker source folder ($DOCKER_SOURCE_DIR)"

	# grant permissions so $DOCKER_ACCOUNT_NAME can copy/execute files from the repo/docker preparation folders
	chmod -R 755 "$DOCKER_SOURCE_DIR"

}

# function to initialize the docker target folder $DOCKER_TARGET_DIR (where the docker project will be built/run) and build/run the container using docker stack.  This function accepts no parameters
# Usage:
# initialize_run_docker_project
function initialize_run_docker_project ()
{
	echo "build the image and deploy the container to swarm"
	
	# copy the necessary files to deploy/upgrade/rollback a specific data system from the $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR to the $DOCKER_TARGET_DIR
	prepare_docker_target_dir

	# switch to the docker project's source directory
	cd "$DOCKER_TARGET_DIR"/docker

	# build and deploy the docker stack
	build_deploy_docker_stack "$DOCKER_IMAGE_NAME" "$DOCKER_STACK_NAME" yes
}


# function to restart the docker container based on the target folder (where the docker project source files exist).  This function accepts 1 parameter (REBUILD_IMAGE which is expected to be yes or no)
# Usage:
# restart_docker_project yes|no
function restart_docker_project ()
{
	echo "restart the docker container (REBUILD_IMAGE = $1)"

	# switch to the docker project's source directory
	cd "$DOCKER_TARGET_DIR"/docker

	# stop the docker stack if it exists:
	remove_docker_stack "$DOCKER_STACK_NAME"

	# set the environment variables needed by the docker container
	export DB_HOST="$DB_HOST"
	export DB_SERVICE_NAME="$DB_SERVICE_NAME"
	export APP_INSTANCE="$APP_INSTANCE"

	# wait for the $DOCKER_NETWORK_NAME to be removed, otherwise it will throw an error when the docker network exists and the docker stack deployment is attempted
	wait_for_docker_network_removal "$DOCKER_NETWORK_NAME"

	# check if the docker image exists:
	if ! docker image inspect "$DOCKER_IMAGE_NAME" &> /dev/null; then
		# the image does not exist, it must be rebuilt even if that was not specified by the function parameter:

		echo ""
		echo "*Notice: The image $DOCKER_IMAGE_NAME was not found, it must be rebuilt"
		echo ""

		# rebuild the image and deploy it as a docker stack
		build_deploy_docker_stack "$DOCKER_IMAGE_NAME" "$DOCKER_STACK_NAME" yes
	
	else

		# if the value of $1 is yes then rebuild the image, if $1 is no then do not rebuild the image.  Then deploy the docker stack
		build_deploy_docker_stack "$DOCKER_IMAGE_NAME" "$DOCKER_STACK_NAME" "$1"

	fi
}