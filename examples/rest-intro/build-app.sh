#!/bin/sh

echo "Building rest-intro application"
mvn package

echo "Building initial application image with rest-intro-application ..."
podman build -t rest-intro-application . || exit 1

echo "Running initial application image to execute checkpoint.sh ..."
podman run --name rest-intro-checkpoint-container --privileged --env WLP_CHECKPOINT=applications rest-intro-application

echo "Committing container rest-intro-checkpoint as image rest-intro"
podman commit rest-intro-checkpoint-container rest-intro-checkpoint || exit 1

echo "Done building image rest-intro ... cleaning up"
podman rm rest-intro-checkpoint-container


