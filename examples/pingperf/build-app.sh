#!/bin/sh


echo "Building initial application image with pingperf-application ..."
docker build -t pingperf-application . || exit 1

echo "Running initial application image to execute checkpoint.sh ..."
docker run --name pingperf-checkpoint-container --privileged --env WLP_CHECKPOINT=applications  pingperf-application
docker wait pingperf-checkpoint-container || exit 1

echo "Committing container pingperf-checkpoint as image pingperf"
docker commit pingperf-checkpoint-container pingperf-checkpoint || exit 1

echo "Done building image pingperf ... cleaning up"
docker rm pingperf-checkpoint-container


