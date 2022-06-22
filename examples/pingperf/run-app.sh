#!/bin/sh

podman run --cap-add=CHECKPOINT_RESTORE --cap-add=NET_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=compprofile.json -v /proc/sys/kernel/ns_last_pid:/proc/sys/kernel/ns_last_pid -p 9080:9080 --name pingperf-restore pingperf-checkpoint; podman rm pingperf-restore



