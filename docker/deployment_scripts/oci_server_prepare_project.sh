#!/bin/sh

echo "preparing the docker project on the docker host"

# remove the docker preparation folder
rm -rf /tmp/docker-staff-info-app

# make the staff-info-app folder for the repository
mkdir -p /tmp/staff-info-app

# clone the project repository
git clone --branch branch_v1.2_docker_secrets git@picgitlab.nmfs.local:omi-apps/staff-info-app.git /tmp/staff-info-app

# prepare the docker project
sh /tmp/staff-info-app/docker/deployment_scripts/prepare_docker_project.sh

# update the permissions so the docker-user can copy the files from the preparation folder into the docker project directory
chmod -R 755 /tmp/docker-staff-info-app

# clean up the files from the cloned repository 
rm -rf /tmp/staff-info-app


# run the deployment script as docker-user
sudo su - docker-user bash /tmp/staff-info-app/docker/deployment_scripts/oci_server_deploy_project.sh



