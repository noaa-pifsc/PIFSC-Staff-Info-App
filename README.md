# Staff Directory Project
The Staff Directory is a docker app with Apache, Perl and Oracle connection drivers hosting a set of PHP scripts that query an Oracle database for the staff directory contents.

## Resources
-   Version Control Information:
    -   URL: https://picgitlab.nmfs.local/omi-apps/staff-directory.git
    -   Application: 1.1 (Git tag: staff_directory_docker_app_v1.1)

## System Requirements
-   Docker

## Image Details
The Docker image is built from the official Oracle InstantClient on OracleLinux 8 [Docker image](https://github.com/oracle/docker-images/blob/main/OracleInstantClient/oraclelinux8/21/Dockerfile). Apache and PHP are installed on the base image.

## Setup
-   ### Docker Application Setup
    -   \*Note: the steps shown here were developed and tested on a Windows computer
    -   #### Project Preparation
        -   Clone the [Staff Directory repository](https://picgitlab.nmfs.local/omi-apps/staff-directory) on the docker host where the container will be deployed
        -   Open the [project_config.sh](./docker/deployment_scripts/sh_script_config/project_config.sh) and set the $root_directory to an appropriate folder path on the computer you are using.
        -   Run the appropriate project preparation script (e.g. [prepare_docker_project.test.sh](./docker/deployment_scripts/prepare_docker_project.test.sh) for the test application) to generate a preparation folder based on the $project_folder variable with the code for the corresponding application instance.
            -   The script will clone the repository in the specified preparation folder and prepare the files to deploy the docker container
        -   Open the credentials file (includes/db_credentials.php) in the preparation folder and specify the database connection information for the database instance the given application will use
    -   #### Docker Deployment
        -   ##### Local Docker Desktop
            -   Execute the deployment_scripts/build_deploy_project.sh script in the preparation folder to build and run the docker container
        -   ##### Docker Host Server (via PuTTY)
            -   Open Pageant
                -   Click "Add CAPI Cert" and choose your CAC credentials
            -   Open PuTTY
                -   login to the specific docker host with your CAC username
                -   Make the temporary directory used to transfer files and grant permissions to read the directory by executing the following command (where [username] is your account username)
                    ```
                    mkdir /tmp/[username]
                    chmod -R 755 /tmp/[username]
                    ```
            -   Open a Command Prompt and change to the prepared folder
                -   Recursively copy the prepared folder contents using the following command (where   [server host] is the hostname/IP address of the docker host server):
                    ```
                    pscp -r ./ [username]@[server host]:/tmp/[username]/
                    ```
            -   In PuTTY, run the following commands to move the prepared files into the specified directory on the docker host server:
                ```
                # switch to the directory containing the prepared folder contents
                cd /tmp/[username]

                # update the permissions on the prepared folder's files
                chmod -R 755 *

                # switch to the docker user
                sudo su - docker-user

                # create the target docker folder where [container folder] is the name of the folder where the docker container will be run from
                mkdir containers/[container folder]

                # switch to the target docker folder where the docker container will be run from
                cd containers/[container folder]

                # shutdown the container (if it is already running)
                docker compose down

                # remove any source files from the target directory:
                rm -rf *

                # copy the files from the prepared folder to the
                rsync -aP /tmp/[username]/* .

                # build and run the container:
                docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d  --build

                # cleanup the container source files in the temporary directory
                rm -rf /tmp/[username]/*
                ```
