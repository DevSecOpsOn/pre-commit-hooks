#!/usr/bin/env bash

# Docker wrapper for trivy
# Image: aquasec/trivy:0.72.0

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../hooks/initialize.sh"

# Docker image and version
TRIVY_IMAGE="aquasec/trivy:0.72.0"

# Parse arguments
SCAN_TYPE="fs"  # default to filesystem scan
TARGET_PATH=""
SEVERITY="UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"
OUTPUT_FORMAT="table"
EXIT_CODE=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --fs)
            SCAN_TYPE="fs"
            shift
            ;;
        --image)
            SCAN_TYPE="image"
            shift
            ;;
        -s|--severity)
            SEVERITY="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -e|--exit-code)
            EXIT_CODE="$2"
            shift 2
            ;;
        --)
            shift
            TARGET_PATH="$1"
            break
            ;;
        *)
            TARGET_PATH="$1"
            shift
            ;;
    esac
done

# If no target specified, exit
if [[ -z "$TARGET_PATH" ]]; then
    echo "Error: No target specified"
    exit 1
fi

# Build docker command
DOCKER_CMD="docker run --rm"

if [[ "$SCAN_TYPE" == "fs" ]]; then
    # Filesystem scan
    if [[ -f "$TARGET_PATH" ]]; then
        # If it's a file, get the directory
        TARGET_DIR="$(cd "$(dirname "$TARGET_PATH")" && pwd)"
        TARGET_FILE="$(basename "$TARGET_PATH")"
        DOCKER_CMD="${DOCKER_CMD} -v '${TARGET_DIR}:/src'"
        SCAN_CMD="fs /src/${TARGET_FILE}"
    elif [[ -d "$TARGET_PATH" ]]; then
        # If it's a directory, use it directly
        TARGET_DIR="$(cd "$TARGET_PATH" && pwd)"
        DOCKER_CMD="${DOCKER_CMD} -v '${TARGET_DIR}:/src'"
        SCAN_CMD="fs /src"
    else
        echo "Error: $TARGET_PATH is not a valid file or directory"
        exit 1
    fi
elif [[ "$SCAN_TYPE" == "image" ]]; then
    # Image scan
    SCAN_CMD="image ${TARGET_PATH}"
fi

# Add severity filter
SEVERITY_ARGS="--severity=${SEVERITY}"

# Add output format
FORMAT_ARGS="--format=${OUTPUT_FORMAT}"

# Add exit code
EXIT_ARGS="--exit-code=${EXIT_CODE}"

# Complete command
DOCKER_CMD="${DOCKER_CMD} ${TRIVY_IMAGE} ${SCAN_CMD} ${SEVERITY_ARGS} ${FORMAT_ARGS} ${EXIT_ARGS}"

# Execute
eval $DOCKER_CMD
