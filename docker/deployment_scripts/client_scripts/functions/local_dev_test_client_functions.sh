#!/bin/bash


# function to deploy a container locally using docker desktop.  The function accepts two parameters, the first is 

function deploy_container_locally ()
{
	# numeric variable to indicate if the local container is a development container (1) to be used with locally mounted folders to allow for rapid development or a test container (0) to be used to verify that the docker secrets configuration is working and suitable for deployment to a docker host
	local IS_DEV_DEPLOYMENT="$1"

	# save/prompt for environment name and SSH username
	set_env_var "$2" 

	# load the bash variables for the runtime configuration
	source ../config/deploy_config.$ENV_NAME.sh
	
	# load the bash database variables as environment variables:
	export DB_HOST
	export DB_SERVICE_NAME

	# clone the project dependencies into the current working copy where the script was executed from:
	git clone $PHP_LIB_GIT_URL ../../src/backend/dependencies/tmp

	# copy the required PHP shared library files into the dependencies directory
	cp -r ../../src/backend/dependencies/tmp/oracle*.php ../../src/backend/dependencies

	# remove the temporary directory
	rm -rf ../../src/backend/dependencies/tmp

	# check if this is a development deployment or not:
    if [[ $IS_DEV_DEPLOYMENT -eq 1 ]]; then

		echo "deploy the container with docker compose for development purposes"

		# change directory into the docker folder that contains the Dockerfile and .yml files
		cd ../../

		# stop and remove any running container
		docker compose down
		
		# build and run the container
		docker compose -f docker-compose.local.dev.yml up -d  --build

    else
		# use docker stack and secrets to test if the code is working for a secure docker host deployment

		echo "deploy the container with docker swarm to test docker secrets"

		# stop the container if it's running so the secrets can be defined/updated
		docker stack rm SIA_stack

		# load the oracle credentials into bash variables
		source ../../secrets/$ENV_NAME/secrets.sh

		# set the docker secrets for the database information based on the bash variables
		set_db_secrets

		# unset the bash variables used to define the secret values
		unset_config_variables

		# change directory into the docker folder that contains the Dockerfile and .yml files
		cd ../../

		# build the docker container
		docker build -t pifsc/staff-info-app:latest -f ./Dockerfile .

		# save and reload image to ensure the latest image is being used in docker swarm
		docker save pifsc/staff-info-app:latest | docker load

		# Deploy the stack
		docker stack deploy -c docker-compose.yml SIA_stack
    fi

}

