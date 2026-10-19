#!/usr/bin/env bash

# Docker wrapper for shellcheck
# Image: koalaman/shellcheck:v0.11.0

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../hooks/initialize.sh"

# Docker image and version
SHELLCHECK_IMAGE="koalaman/shellcheck:v0.11.0"

# Parse arguments
SCRIPT_FILES=()
SEVERITY=""
OUTPUT_FORMAT="tty"
EXCLUDE_CHECKS=""
EXTERNAL_SOURCES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--severity)
            SEVERITY="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -e|--exclude)
            EXCLUDE_CHECKS="$2"
            shift 2
            ;;
        -x|--external-sources)
            EXTERNAL_SOURCES=true
            shift
            ;;
        --)
            shift
            SCRIPT_FILES=("$@")
            break
            ;;
        *)
            SCRIPT_FILES+=("$1")
            shift
            ;;
    esac
done

# If no script files specified, exit
if [[ ${#SCRIPT_FILES[@]} -eq 0 ]]; then
    echo "Error: No script files specified"
    exit 1
fi

# Build docker command
DOCKER_CMD="docker run --rm"

# Build volume mounts and file paths
VOLUMENS=""
CONTAINER_FILES=""
for script in "${SCRIPT_FILES[@]}"; do
    if [[ -f "$script" ]]; then
        SCRIPT_DIR="$(cd "$(dirname "$script")" && pwd)"
        SCRIPT_NAME="$(basename "$script")"
        VOLUMENS="${VOLUMENS} -v '${SCRIPT_DIR}:/workdir_${SCRIPT_NAME}'"
        CONTAINER_FILES="${CONTAINER_FILES} /workdir_${SCRIPT_NAME}/${SCRIPT_NAME}"
    fi
done

DOCKER_CMD="${DOCKER_CMD} ${VOLUMENS}"

# Add severity if specified
if [[ -n "$SEVERITY" ]]; then
    SEVERITY_ARGS="--severity=${SEVERITY}"
fi

# Add output format if specified
if [[ -n "$OUTPUT_FORMAT" ]]; then
    FORMAT_ARGS="--format=${OUTPUT_FORMAT}"
fi

# Add exclude checks if specified
if [[ -n "$EXCLUDE_CHECKS" ]]; then
    EXCLUDE_ARGS="--exclude=${EXCLUDE_CHECKS}"
fi

# Add external sources if specified
if [[ "$EXTERNAL_SOURCES" == true ]]; then
    EXTERNAL_ARGS="--external-sources"
fi

# Complete command
DOCKER_CMD="${DOCKER_CMD} ${SHELLCHECK_IMAGE} ${SEVERITY_ARGS} ${FORMAT_ARGS} ${EXCLUDE_ARGS} ${EXTERNAL_ARGS} ${CONTAINER_FILES}"

# Execute
eval $DOCKER_CMD
