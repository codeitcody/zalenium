#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
set -e

# /usr/bin/docker exists when docker run has
#   -v $(which docker):/usr/bin/docker
if [ -f /usr/bin/docker ]; then
    echo "Docker binary already present, will use that one."
else
    # Grab the complete docker version `1.12.5` out of the partial one `1.12`
    export DOCKER_VERSION=$(ls /usr/bin/docker-${DOCKER}* | grep -Po '(?<=docker-)([a-z0-9\.]+)' | head -1)
    # Link the docker binary to the selected docker version via e.g. `-e DOCKER=1.11`
    if [ -f /usr/bin/docker-${DOCKER_VERSION} ]; then
        sudo ln -s /usr/bin/docker-${DOCKER_VERSION} /usr/bin/docker
    else
        echo "Something went wrong trying to find DOCKER_VERSION=${DOCKER_VERSION} with DOCKER=${DOCKER}"
        ls -la /usr/bin/docker*
        echo "Trying to fetch latest docker binary at /usr/bin/docker*"
        DOCKER_BIN=$(ls -U /usr/bin/docker* | sort -r | head -1)
        if [ -f ${DOCKER_BIN} ]; then
            sudo ln -s ${DOCKER_BIN} /usr/bin/docker
        else
            echo "FATAL: Last attempt to find a valid docker binary to use failed."
            echo "FATAL: DOCKER_BIN=${DOCKER_BIN}"
            exit 1
        fi
    fi
fi

# Make sure Docker works before continuing
docker --version
sudo docker images elgalu/selenium >/dev/null

# To run docker alongside docker we still need sudo inside the container
# TODO: this can potentially be fixed perhaps by passing $UID
#       during docker run time.
exec sudo --preserve-env ./zalenium.sh "$@"
