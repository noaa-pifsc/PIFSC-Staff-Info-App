#!/bin/sh

# switch to the docker project's source directory
cd ~/containers/staff-directory/

# stop the running container
docker stack rm staff-info-app

# remove the files in the staff-directory container directory
rm -rf ~/containers/staff-directory/*

# copy the docker files from the 
rsync -aP /tmp/docker-staff-info-app/* ~/containers/staff-directory

# build the docker container
docker build -t staff-info-app:latest -f ./Dockerfile .

# Deploy the stack
docker stack deploy -c docker-compose.yml staff-info-app