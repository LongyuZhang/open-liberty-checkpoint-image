#!/bin/sh


# Use this if running with runc version 1.1.3 or higher
# podman run --cap-add=CHECKPOINT_RESTORE --cap-add=NET_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=compprofile.json -v /proc/sys/kernel/ns_last_pid:/proc/sys/kernel/ns_last_pid -p 9080:9080 --name rest-intro-restore rest-intro-checkpoint; podman rm rest-intro-restore

# Use this if running with runc version lower than 1.1.3
# The extra --security-opt for seccomp systempaths and apparmor
# are needed if not using the latest runc release
# that allows mounting of ns_last_pid
podman run --cap-add=CHECKPOINT_RESTORE --cap-add=NET_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --security-opt systempaths=unconfined --security-opt apparmor=unconfined -p 9080:9080 --name rest-intro-restore rest-intro-checkpoint; podman rm rest-intro-restore


