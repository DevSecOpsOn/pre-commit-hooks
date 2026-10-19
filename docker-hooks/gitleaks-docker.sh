#!/usr/bin/env bash

# Docker wrapper for gitleaks
# Image: zricethezav/gitleaks:v8.30.1

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../hooks/initialize.sh"

# Docker image and version
GITLEAKS_IMAGE="zricethezav/gitleaks:v8.30.1"

# Parse arguments
SOURCE_DIR=""
OUTPUT_FORMAT=""
VERBOSE=false
CONFIG_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            if [[ -z "$SOURCE_DIR" ]]; then
                SOURCE_DIR="$1"
            fi
            shift
            ;;
    esac
done

# Default to current directory if no source specified
if [[ -z "$SOURCE_DIR" ]]; then
    SOURCE_DIR="."
fi

# Convert to absolute path
if [[ -f "$SOURCE_DIR" ]]; then
    # If it's a file, get the directory and filename
    REAL_SOURCE_DIR="$SOURCE_DIR"
    SOURCE_DIR="$(cd "$(dirname "$REAL_SOURCE_DIR")" && pwd)"
    SOURCE_FILE="$(basename "$REAL_SOURCE_DIR")"
elif [[ -d "$SOURCE_DIR" ]]; then
    # If it's a directory, use it directly
    SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
    SOURCE_FILE=""
else
    echo "Error: $SOURCE_DIR is not a valid file or directory"
    exit 1
fi

# Build docker command
DOCKER_CMD="docker run --rm -v '${SOURCE_DIR}:/src'"

# Add config file if specified
if [[ -n "$CONFIG_FILE" ]]; then
    CONFIG_DIR="$(cd "$(dirname "$CONFIG_FILE")" && pwd)"
    CONFIG_FILE="$(basename "$CONFIG_FILE")"
    DOCKER_CMD="${DOCKER_CMD} -v '${CONFIG_DIR}:/config'"
    CONFIG_ARGS="--config=/config/${CONFIG_FILE}"
fi

# Add output format if specified
if [[ -n "$OUTPUT_FORMAT" ]]; then
    FORMAT_ARGS="--format=${OUTPUT_FORMAT}"
fi

# Add verbose flag if specified
if [[ "$VERBOSE" == true ]]; then
    VERBOSE_ARGS="--verbose"
fi

# Complete command
if [[ -n "$SOURCE_FILE" ]]; then
    DOCKER_CMD="${DOCKER_CMD} ${GITLEAKS_IMAGE} detect --source=/src/${SOURCE_FILE} ${CONFIG_ARGS} ${FORMAT_ARGS} ${VERBOSE_ARGS}"
else
    DOCKER_CMD="${DOCKER_CMD} ${GITLEAKS_IMAGE} detect --source=/src ${CONFIG_ARGS} ${FORMAT_ARGS} ${VERBOSE_ARGS}"
fi

# Execute
eval $DOCKER_CMD
