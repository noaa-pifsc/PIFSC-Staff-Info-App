#! /bin/sh

# change to the root directory where the dockerfile exists
cd ../

# build and execute the docker container for the development scenario
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d  --build

# notify the user that the container has finished executing
echo "The dev docker container has finished building and is running"

read
