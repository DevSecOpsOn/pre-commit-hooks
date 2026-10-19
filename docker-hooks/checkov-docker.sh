#!/usr/bin/env bash

# Docker wrapper for checkov
# Image: bridgecrew/checkov:3.3.7

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../hooks/initialize.sh"

# Docker image and version
CHECKOV_IMAGE="bridgecrew/checkov:3.3.7"

# Parse arguments
DIRECTORY=""
FRAMEWORK=""
OUTPUT_FORMAT="cli"
SOFT_FAIL=false
COMPACT=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--directory)
            DIRECTORY="$2"
            shift 2
            ;;
        -f|--framework)
            FRAMEWORK="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -s|--soft-fail)
            SOFT_FAIL=true
            shift
            ;;
        -c|--compact)
            COMPACT=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            if [[ -z "$DIRECTORY" ]]; then
                DIRECTORY="$1"
            fi
            shift
            ;;
    esac
done

# If no directory specified, use current directory
if [[ -z "$DIRECTORY" ]]; then
    DIRECTORY="."
fi

# Convert to absolute path
if [[ -f "$DIRECTORY" ]]; then
    # If it's a file, get the directory
    DIRECTORY="$(cd "$(dirname "$DIRECTORY")" && pwd)"
elif [[ -d "$DIRECTORY" ]]; then
    # If it's a directory, use it directly
    DIRECTORY="$(cd "$DIRECTORY" && pwd)"
else
    echo "Error: $DIRECTORY is not a valid file or directory"
    exit 1
fi

# Build docker command
DOCKER_CMD="docker run --rm -v '${DIRECTORY}:/tf' -w /tf"

# Add framework if specified
if [[ -n "$FRAMEWORK" ]]; then
    FRAMEWORK_ARGS="--framework ${FRAMEWORK}"
fi

# Add output format
OUTPUT_ARGS="--output ${OUTPUT_FORMAT}"

# Add soft fail if specified
if [[ "$SOFT_FAIL" == true ]]; then
    SOFT_FAIL_ARGS="--soft-fail"
fi

# Add compact if specified
if [[ "$COMPACT" == true ]]; then
    COMPACT_ARGS="--compact"
fi

# Add quiet if specified
if [[ "$QUIET" == true ]]; then
    QUIET_ARGS="--quiet"
fi

# Complete command
DOCKER_CMD="${DOCKER_CMD} ${CHECKOV_IMAGE} --directory /tf ${FRAMEWORK_ARGS} ${OUTPUT_ARGS} ${SOFT_FAIL_ARGS} ${COMPACT_ARGS} ${QUIET_ARGS}"

# Execute
eval $DOCKER_CMD
