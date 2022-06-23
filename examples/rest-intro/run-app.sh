#!/bin/sh

podman run --cap-add=CHECKPOINT_RESTORE --cap-add=NET_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=compprofile.json -v /proc/sys/kernel/ns_last_pid:/proc/sys/kernel/ns_last_pid -p 9080:9080 --name rest-intro-restore rest-intro-checkpoint; podman rm rest-intro-restore



