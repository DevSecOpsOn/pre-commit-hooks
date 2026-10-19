#!/usr/bin/env bash

# Docker wrapper for hadolint
# Image: hadolint/hadolint:v2.14.0-alpine

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../hooks/initialize.sh"

# Docker image and version
HADOLINT_IMAGE="hadolint/hadolint:v2.14.0-alpine"

# Parse arguments - pre-commit passes files as arguments
DOCKERFILE_PATH="$1"

# If no dockerfile specified, exit
if [[ -z "$DOCKERFILE_PATH" ]]; then
    echo "Error: No Dockerfile specified"
    exit 1
fi

# Convert to absolute path
DOCKERFILE_PATH="$(cd "$(dirname "$DOCKERFILE_PATH")" && pwd)/$(basename "$DOCKERFILE_PATH")"
DOCKERFILE_DIR="$(dirname "$DOCKERFILE_PATH")"

# Build docker command
DOCKER_CMD="docker run --rm -v '${DOCKERFILE_DIR}:/workdir'"

# Get dockerfile name for container
DOCKERFILE_NAME="$(basename "$DOCKERFILE_PATH")"

# Complete command - run hadolint with default settings
DOCKER_CMD="${DOCKER_CMD} ${HADOLINT_IMAGE} hadolint /workdir/${DOCKERFILE_NAME}"

# Execute
eval $DOCKER_CMD
