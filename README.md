# Open Liberty Checkpoint / Restore Image
This repository contains the necessary resources and instructions for building and using an open-liberty container image that supports Checkpoint / Restore using [CRIU](https://criu.org).  The files in this repository are only meant to provide an example of what the support could eventually look like once it is officially included in a beta release from the [Open Liberty](https://github.com/OpenLiberty/open-liberty) project.  It includes copies of several files from the Open Liberty [ci.docker](https://github.com/OpenLiberty/ci.docker) repository, particularly from the directory that builds the beta container images for Open Liberty.

The instructions in this repostitory assume running locally on an amd64/x86-64 based Linux host that, at a minimum, is running a kernel that supports the linux [capability](https://man7.org/linux/man-pages/man7/capabilities.7.html) `CAP_CHECKPOINT_RESTORE`. It is also assumed that the user is a privileged user that can run `sudo` commands. The examples use `podman` to build the containers but other container build technologies should also be able to process the `Dockerfile` resources in this repository.

# Bulding open-liberty:beta-checkpoint-ubi Image
First the `open-liberty:beta-checkpoint-ubi` image needs to be built.  Once the `open-liberty:beta-checkpoint-ubi` image is built it can be used to containerize and checkpoint an application with Open Liberty.  The `open-liberty:beta-checkpoint-ubi` image, once built, contains all the prerequisites required for doing a checkpoint and restore of the application.  This includes the following:
1. A version of `criu` that supports an unprivileged user
2. A version of [OpenJ9](https://github.com/eclipse-openj9/openj9) that supports checkpointing the JVM
3. A version of [Open Liberty](https://github.com/OpenLiberty/open-liberty) that supports checkpointing a Liberty server configuraiton

Currently OpenJ9 builds that support checkpointing the JVM are x86-64 only, therefore the only `open-liberty:beta-checkpoint-ubi` image that can currently be built is x86-64 only.  The instructions here also only produce a UBI based image.  It is possible that an Ubuntu image could be produced, but the UBI based images are the focus first.

To build the `open-liberty:beta-checkpoint-ubi` image simply run the following command as root or using the `sudo` command if you are a privileged user from the root directory of this repository:

```
podman build -f beta-image/Dockerfile.ubi.openjdk11 -t open-liberty:beta-checkpoint-ubi beta-image
```

# Using open-liberty:beta-checkpoint-ubi Image
After the `open-liberty:beta-checkpoint-ubi` image has been built locally you can use the following steps the containerize your application and then checkpoint your application and build a layer on top that contains a checkpointed instance of your application.
## Containerize an application
For a more indepth look at containerizing your application with Open Liberty go to the Open Liberty [guides](https://openliberty.io/guides/).  In particular look at the [containerize](https://openliberty.io/guides/#containerize) guides.

A minimal `Dockerfile` using the open-liberty:beta-checkpoint image would look similar to the following:

```
FROM open-liberty:beta-checkpoint-ubi

ARG VERBOSE=false

COPY --chown=1001:0 server.xml /config/server.xml
COPY --chown=1001:0 pingperf.war /config/dropins/pingperf.war

RUN configure.sh
```
To build an application image using this `Dockerfile` use something like the following:

```
podman build -t ping-application .
```

## Checkpoint an application in-container
Once a containerized application image has been created it can be used to checkpoint the Open Liberty server process which has been configured to run the containerized application. The checkpoint can be done at one of the three following spots during the Open Liberty server startup:

1. features - performs the checkpoint after the configured Open Liberty features have been started and are ready to start processing the configured applications.
2. deployment - performs the checkpoint after the configured applications have been processed and are ready to start
3. applications - performs the checkpoint after the configured applications have been started, but before any ports have been opened to accept incoming requests to the application

To perform the checkpoint of an application in-container run the following command, where the <application-image-name> is the image tag used when the applicaiion was containerized and <application-image-name-container> is the name for the temporary container which will be used to checkpoint the application:
```
podman run --name <application-image-name-container> --privileged --env WLP_CHECKPOINT=applications <application-image-name>
```
This will start a container with the containerized application running on Open Liberty.  Once Open Liberty starts it will perform a checkpoint at the spot specified by the `WLP_CHECKPOINT` environment variable specified by the `--env` options.  This variable can be set to `features`, `deployment` or `applications`.  Note that `--privileged` is required to perform the checkpoint in-container.  This is only necessary to produce the checkpoing process image which gets stored into the container.  After the checkpoint process image has been produced the container will stop, leaving you with a stopped container that contains the checkpoint process image.

## Commit a checkpointed application image
To produce a checkpointed application container image which contains the checkpoint process image run the following command that will commit the container used to run the checkpoint to an application image where <application-image-name-container> is the name used above for the container used to checkpoint and <application-image-name-checkpoint> is the final name you want the checkpointed application container image to be:
```
podman commit <application-image-name-container> <application-image-name-checkpoint> || exit 1
```
## Restore a checkpointed application in-container
To restore the checkpointed application in-container you run the checkpointed application container image.  Typically that would be done with a command like this, where <application-image-name-checkpoint> is the final name you used to build the checkpointed application container image:

```
podman run -it -p 9080:9080 <application-image-name-checkpoint>
```

This will fail because `criu` needs some elevated privileges in order to be able to restore the process in-container.  The following command can be used to grant the contianer the necessary privileges without running a fully `--privileged` container:

```
podman run --cap-add=CHECKPOINT_RESTORE --cap-add=NET_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=criuRequiredSysCalls.json -v /proc/sys/kernel/ns_last_pid:/proc/sys/kernel/ns_last_pid -p 9080:9080  <application-image-name-checkpoint>
```

## Simple Example
The [pingperf](examples/pingperf) directory contains a very simple REST application called pingperf along with the necessary `Dockerfile` to containerize the application.  It also contains a simple script `build-app.sh` that performs the steps above to build a `pingperf-checkpoint` image.  It also contains a simple `run-app.sh` script for restoring the application process in-container.

