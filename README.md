# Open Liberty Checkpoint / Restore Image
This repository contains the necessary resources and instructions for building and using an open-liberty container image that supports Checkpoint / Restore using [CRIU](https://criu.org).  The files in this repository are only meant to provide an example of what the support could eventually look like once it is officially included in a beta release from the [Open Liberty](https://github.com/OpenLiberty/open-liberty) project.  It includes copies of several files from the Open Liberty [ci.docker](https://github.com/OpenLiberty/ci.docker) repository, particularly from the directory that builds the beta container images for Open Liberty.

The instructions in this repostitory assume running locally on an amd64/x86-64 based Linux host that, at a minimum, is running a kernel that supports the linux [capability](https://man7.org/linux/man-pages/man7/capabilities.7.html) `CAP_CHECKPOINT_RESTORE`. It is also assumed that the user is a privileged user that can run `sudo` commands. The examples use `podman` to build the containers but other container build technologies should also be able to process the `Dockerfile` resources in this repository.

# Bulding open-liberty:beta-checkpoint-ubi Image
First the `open-liberty:beta-checkpoint-ubi` image needs to be built.  Once the `open-liberty:beta-checkpoint-ubi` image is built it can be used to containerize and checkpoint an application with Open Liberty.  The `open-liberty:beta-checkpoint-ubi` image, once built, contains all the prerequisites required for doing a checkpoint and restore of the application.  This includes the following:
1. A version of `criu` that supports an unprivileged user
2. A version of [OpenJ9](https://github.com/eclipse-openj9/openj9) that supports checkpointing the JVM
3. A version of [Open Liberty]([Open Liberty](https://github.com/OpenLiberty/open-liberty)) that supports checkpointing a Liberty server configuraiton

Currently OpenJ9 builds that support checkpointing the JVM are x86-64 only, therefore the only `open-liberty:beta-checkpoint-ubi` image that can currently be built is x86-64 only.  The instructions here also only produce a UBI based image.  It is possible that an Ubuntu image could be produced, but the UBI based images are the focus first.

To build the `open-liberty:beta-checkpoint-ubi` image simply run the following command as root or using the `sudo` command if you are a privileged user from the root directory of this repository:

```
podman build -f beta-image/Dockerfile.ubi.openjdk11 -t open-liberty:beta-checkpoint-ubi beta-image
```

# Using open-liberty:beta-checkpoint-ubi Image

## Containerize an application
## Checkpoint an application in-container
## Commit a checkpointed application image
## Restore a checkpointed application in-container 
