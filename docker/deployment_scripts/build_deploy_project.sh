#! /bin/sh

# build and execute the docker container for the development scenario
docker-compose -f ../docker-compose.yml up -d  --build

# notify the user that the container has finished executing
echo "The docker container has finished building and is running"