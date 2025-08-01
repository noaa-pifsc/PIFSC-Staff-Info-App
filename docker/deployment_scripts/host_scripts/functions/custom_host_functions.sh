#!/bin/bash


# function to copy the necessary files to deploy/upgrade/rollback a specific data system from the $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR to the $DOCKER_TARGET_DIR
# Usage:
# prepare_docker_target_dir
function prepare_docker_target_dir ()
{
	# sync files to docker source directory:
	echo "Copy the ${DOCKER_PREP_FOLDER_PATH} source files to the destination directory: ${DOCKER_TARGET_DIR} so they can used to build/deploy container"

	# copy the docker files to the root $DOCKER_TARGET_DIR
	rsync -a "$DOCKER_PREP_FOLDER_PATH"/* "$DOCKER_TARGET_DIR"
}

# function to prepare the docker preparation folder that will be copied to 
function prepare_docker_prep_folder ()
{
	echo "prepare the docker preparation folder"

	# create the temporary folder that the repos will be copied to
	mkdir -p $DOCKER_REPO_FOLDER_PATH/tmp

	echo "create the web folder structure"
	mkdir $DOCKER_REPO_FOLDER_PATH/www

	echo "create the backend folder structure"
	mkdir -p $DOCKER_REPO_FOLDER_PATH/backend/$SIA_PROJECT_FOLDER
	mkdir $DOCKER_REPO_FOLDER_PATH/backend/$SHARED_LIBRARY_FOLDER




	echo "clone the project dependencies"
	git clone $php_lib_git_url $DOCKER_REPO_FOLDER_PATH/tmp/$SHARED_LIBRARY_FOLDER

	# copy the php-shared-library (oracle .php files only)
	echo "copy the php-shared-library backend directory"
	cp -r $DOCKER_REPO_FOLDER_PATH/tmp/$SHARED_LIBRARY_FOLDER/oracle*.php  $DOCKER_REPO_FOLDER_PATH/backend/$SHARED_LIBRARY_FOLDER

	# remove the working directories where the files in the export folder were prepared from
	echo "remove all temporary files"
	rm -rf $DOCKER_REPO_FOLDER_PATH/tmp


	echo "copy source code/docker files for the SIA from the current repo"

	## copy the files in the docker directory
	cp -R ../* $DOCKER_REPO_FOLDER_PATH

	## remove the unnecessary deployment_scripts files
	rm -rf $DOCKER_REPO_FOLDER_PATH/deployment_scripts/sh_script_config
	rm $DOCKER_REPO_FOLDER_PATH/deployment_scripts/prepare_docker_project.sh
	rm $DOCKER_REPO_FOLDER_PATH/deployment_scripts/oci_server_deploy_project.sh
	rm $DOCKER_REPO_FOLDER_PATH/deployment_scripts/oci_server_prepare_project.sh

	# copy the source files to the www directory:
	cp -R ../../src/frontend/* $DOCKER_REPO_FOLDER_PATH/www 

	# copy the backend source files to the backend/$project_folder directory:
	cp -R ../../src/backend/* $DOCKER_REPO_FOLDER_PATH/backend/$sia_project_folder

	# grant permissions so docker-user can copy/execute files from the repo/docker preparation folders
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

	# stop the running container
	docker stack rm pifsc/staff-info-app

	# remove the files in the staff-directory container directory
	rm -rf "$DOCKER_TARGET_DIR"/*

	# copy the docker files from the preparation folder to the docker target source directory
	rsync -aP "$DOCKER_PREP_FOLDER_PATH"/* "$DOCKER_TARGET_DIR"

	# build the docker container
	docker build -t pifsc/staff-info-app:latest -f ./Dockerfile .

	# save and reload image to ensure the latest image is being used in docker swarm
	docker save pifsc/staff-info-app:latest | docker load

	# Deploy the stack
	docker stack deploy -c docker-compose.yml staff-info-app

}

# function to set the database secrets from bash variables:
function set_db_secrets ()
{
	echo "running set_db_secrets()"

	#set the database username secret value
	create_secret "sia_db_username_secret" "$DB_USERNAME"

	#set the database password secret value
	create_secret "sia_db_password_secret" "$DB_PASSWORD"

}