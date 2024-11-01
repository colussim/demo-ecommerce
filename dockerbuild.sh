#!/bin/bash

#variables
DOCKER_USER="xxxxx" 
IMAGE_NAME_ECOMMERCEP="ecommercep"
VERSION="1.0.1"
CMD="podman"

DIR="Docker/v${VERSION}"

TAG="demo"

cd ${DIR}

# Build images
${CMD} build -t ${IMAGE_NAME_ECOMMERCEP}:${VERSION} .

# Login to Docker Hub
${CMD} login docker.io

podman tag localhost/${IMAGE_NAME_ECOMMERCEP}:${VERSION} docker.io/${DOCKER_USER}/${IMAGE_NAME_ECOMMERCEP}:${VERSION}


# Push images 
podman push docker.io/${DOCKER_USER}/${IMAGE_NAME_ECOMMERCEP}:${VERSION}




