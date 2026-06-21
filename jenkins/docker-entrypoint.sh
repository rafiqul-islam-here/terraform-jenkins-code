#!/bin/bash
set -e

# Add Jenkins user to Docker socket group
if [ -S /var/run/docker.sock ]; then
    DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

    if ! getent group "$DOCKER_GID" >/dev/null; then
        groupadd -g "$DOCKER_GID" dockerhost
    fi

    usermod -aG "$DOCKER_GID" jenkins
fi

# Start Jenkins
exec gosu jenkins /usr/bin/tini -- /usr/local/bin/jenkins.sh