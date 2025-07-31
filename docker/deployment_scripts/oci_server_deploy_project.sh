#!/bin/sh

# shutdown the container if it's already running 
docker compose -f ~/containers/staff-directory/docker-compose.yml down

# remove the files in the staff-directory container directory
rm -rf ~/containers/staff-directory/*

# copy the docker files from the 
rsync -aP /tmp/docker-staff-info-app/* ~/containers/staff-directory

# build and run the docker container
docker compose -f ~/containers/staff-directory/docker-compose.yml up -d --build
