#!/usr/bin/env bash

# Docker wrapper for yamllint
# Image: volkerraschek/yamllint:1.38.0

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../hooks/initialize.sh"

# Docker image and version
YAMLLINT_IMAGE="volkerraschek/yamllint:1.38.0"

# Parse arguments
YAML_FILES=()
CONFIG_FILE=""
STRICT_MODE=false
OUTPUT_FORMAT="standard"

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -s|--strict)
            STRICT_MODE=true
            shift
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        --)
            shift
            YAML_FILES=("$@")
            break
            ;;
        *)
            YAML_FILES+=("$1")
            shift
            ;;
    esac
done

# If no yaml files specified, exit
if [[ ${#YAML_FILES[@]} -eq 0 ]]; then
    echo "Error: No YAML files specified"
    exit 1
fi

# Build docker command
DOCKER_CMD="docker run --rm"

# Build volume mounts and file paths
VOLUMENS=""
CONTAINER_FILES=""
for yaml_file in "${YAML_FILES[@]}"; do
    if [[ -f "$yaml_file" ]]; then
        YAML_DIR="$(cd "$(dirname "$yaml_file")" && pwd)"
        YAML_NAME="$(basename "$yaml_file")"
        VOLUMENS="${VOLUMENS} -v '${YAML_DIR}:/workdir_${YAML_NAME}'"
        CONTAINER_FILES="${CONTAINER_FILES} /workdir_${YAML_NAME}/${YAML_NAME}"
    fi
done

DOCKER_CMD="${DOCKER_CMD} ${VOLUMENS}"

# Add config file if specified
if [[ -n "$CONFIG_FILE" ]]; then
    CONFIG_DIR="$(cd "$(dirname "$CONFIG_FILE")" && pwd)"
    CONFIG_NAME="$(basename "$CONFIG_FILE")"
    DOCKER_CMD="${DOCKER_CMD} -v '${CONFIG_DIR}:/config'"
    CONFIG_ARGS="-c /config/${CONFIG_NAME}"
fi

# Add strict mode if specified
if [[ "$STRICT_MODE" == true ]]; then
    STRICT_ARGS="--strict"
fi

# Add output format if specified
if [[ -n "$OUTPUT_FORMAT" ]]; then
    FORMAT_ARGS="--format=${OUTPUT_FORMAT}"
fi

# Complete command
DOCKER_CMD="${DOCKER_CMD} ${YAMLLINT_IMAGE} ${CONFIG_ARGS} ${STRICT_ARGS} ${FORMAT_ARGS} ${CONTAINER_FILES}"

# Execute
eval $DOCKER_CMD
