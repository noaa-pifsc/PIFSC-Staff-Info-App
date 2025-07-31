#!/bin/sh

# switch to the docker project's source directory
cd ~/containers/staff-directory/

# stop the running container
docker stack rm pifsc/staff-info-app

# remove the files in the staff-directory container directory
rm -rf ~/containers/staff-directory/*

# copy the docker files from the 
rsync -aP /tmp/docker-staff-info-app/* ~/containers/staff-directory

# build the docker container
docker build -t pifsc/staff-info-app:latest -f ./Dockerfile .

# save and reload image to ensure the latest image is being used in docker swarm
docker save pifsc/staff-info-app:latest | docker load

# Deploy the stack
docker stack deploy -c docker-compose.yml staff-info-app