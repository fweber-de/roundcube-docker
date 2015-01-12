#!/bin/bash

set -eux

DOCKER=docker
PORT=${PORT:-8081}

# hack for debian
if which docker.io; then
    DOCKER=docker.io
fi

# 0. Create roundcube-data container to host only data
set +e
$DOCKER ps -a | grep roundcube-data
RESULT=$?
set -e

if [ $RESULT = 0 ]; then
    true
else
    $DOCKER run -v /rc --name roundcube-data busybox mkdir -p /rc
fi

# 1. Create image with roundcube
$DOCKER build -t thinred/roundcube ./roundcube

# 2. Start it and attach rc-data volumes
$DOCKER run --restart=always -p $PORT:80 --volumes-from roundcube-data -d --name roundcube thinred/roundcube
