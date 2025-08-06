#!/bin/bash


# function to copy the necessary files to deploy/upgrade/rollback a specific data system from the $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR to the $DOCKER_TARGET_DIR
# Usage:
# prepare_docker_target_dir
function prepare_docker_target_dir ()
{
	# sync files to docker source directory:
	echo "Copy the ${DOCKER_SOURCE_DIR}/docker source files to the destination directory: ${DOCKER_TARGET_DIR} so they can used to build/deploy container"

	# copy the docker files to the root $DOCKER_TARGET_DIR
	rsync -a "$DOCKER_SOURCE_DIR"/docker/* "$DOCKER_TARGET_DIR"
}

# function to prepare the docker preparation folder that will be copied to 
function prepare_docker_prep_folder ()
{
	echo "prepare the docker preparation folder"

	echo "clone the project dependencies"
	git clone $PHP_LIB_GIT_URL $DOCKER_SOURCE_DIR/docker/src/backend/dependencies/tmp

	# copy the required PHP shared library files into the dependencies directory
	cp -r $DOCKER_SOURCE_DIR/docker/src/backend/dependencies/tmp/oracle*.php $DOCKER_SOURCE_DIR/docker/src/backend/dependencies

	# remove the temporary directory
	rm -rf $DOCKER_SOURCE_DIR/docker/src/backend/dependencies/tmp

	# grant permissions so $DOCKER_ACCOUNT_NAME can copy/execute files from the repo/docker preparation folders
	chmod -R 755 "$DOCKER_SOURCE_DIR"

}



# function to initialize the docker target folder (where the docker project will be built/run) and build/run the container.  This function accepts no parameters
# Usage:
# initialize_run_docker_project
function initialize_run_docker_project ()
{
	# load the configuration variables
	source ../config/docker_host_config.sh

	# copy the necessary files to deploy/upgrade/rollback a specific data system from the $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR to the $DOCKER_TARGET_DIR
	prepare_docker_target_dir

	# switch to the docker project's source directory
	cd "$DOCKER_TARGET_DIR"


	# remove the files in the staff-directory container directory
	rm -rf "$DOCKER_TARGET_DIR"/*

	# copy the docker files from the preparation folder to the docker target source directory
	rsync -aP "$DOCKER_SOURCE_DIR"/docker/* "$DOCKER_TARGET_DIR"

	# build the docker container
	docker build -t pifsc/staff-info-app:latest -f ./Dockerfile .

	# save and reload image to ensure the latest image is being used in docker swarm
	docker save pifsc/staff-info-app:latest | docker load

	# Deploy the stack
	docker stack deploy -c docker-compose.yml SIA_stack

}