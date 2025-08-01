#!/bin/sh

echo "preparing the docker project on the docker host"


# make the staff-info-app folder for the repository and switch to it
mkdir -p /tmp/staff-info-app
cd /tmp/staff-info-app

# clone the project repository
git clone --branch branch_v1.2_docker_secrets git@picgitlab.nmfs.local:omi-apps/staff-info-app.git /tmp/staff-info-app

# prepare the docker project
sh /tmp/staff-info-app/docker/deployment_scripts/prepare_docker_project.sh

# update the permissions so the docker-user can copy the files from the preparation folder into the docker project directory
chmod -R 755 /tmp/docker-staff-info-app

# update the permissions so the docker-user can execute the deployment scripts
chmod -R 755 /tmp/staff-info-app

DEPLOY_SCRIPT="/tmp/staff-info-app/docker/deployment_scripts/oci_server_deploy_project.sh"

# run the deployment script as docker-user
sudo su - docker-user <<EOF
echo "Running deployment script as user: \$(whoami)"
bash ${DEPLOY_SCRIPT}
EOF


# clean up the files from the cloned repository 
rm -rf /tmp/staff-info-app

# remove the docker preparation folder
rm -rf /tmp/docker-staff-info-app
