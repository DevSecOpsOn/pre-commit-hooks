#!/usr/bin/env bash

# Docker wrapper for kube-score
# Image: zegl/kube-score:v1.20.0

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../hooks/initialize.sh"

# Docker image and version
KUBESCORE_IMAGE="zegl/kube-score:v1.20.0"

# Parse arguments
K8S_FILES=()
OUTPUT_FORMAT="human"
VERBOSE=false
IGNORE_TESTS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output-format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --ignore-test)
            IGNORE_TESTS+=("$2")
            shift 2
            ;;
        --)
            shift
            K8S_FILES=("$@")
            break
            ;;
        *)
            K8S_FILES+=("$1")
            shift
            ;;
    esac
done

# If no k8s files specified, exit
if [[ ${#K8S_FILES[@]} -eq 0 ]]; then
    echo "Error: No Kubernetes files specified"
    exit 1
fi

# Build docker command
DOCKER_CMD="docker run --rm"

# Build volume mounts and file paths
VOLUMENS=""
CONTAINER_FILES=""
for k8s_file in "${K8S_FILES[@]}"; do
    if [[ -f "$k8s_file" ]]; then
        K8S_DIR="$(cd "$(dirname "$k8s_file")" && pwd)"
        K8S_NAME="$(basename "$k8s_file")"
        VOLUMENS="${VOLUMENS} -v '${K8S_DIR}:/workdir_${K8S_NAME}'"
        CONTAINER_FILES="${CONTAINER_FILES} /workdir_${K8S_NAME}/${K8S_NAME}"
    fi
done

DOCKER_CMD="${DOCKER_CMD} ${VOLUMENS}"

# Add output format if specified
if [[ -n "$OUTPUT_FORMAT" ]]; then
    FORMAT_ARGS="--output-format=${OUTPUT_FORMAT}"
fi

# Add verbose flag if specified
if [[ "$VERBOSE" == true ]]; then
    VERBOSE_ARGS="--verbose"
fi

# Add ignore tests if specified
for test in "${IGNORE_TESTS[@]}"; do
    IGNORE_ARGS="${IGNORE_ARGS} --ignore-test=${test}"
done

# Complete command
DOCKER_CMD="${DOCKER_CMD} ${KUBESCORE_IMAGE} score ${FORMAT_ARGS} ${VERBOSE_ARGS} ${IGNORE_ARGS} ${CONTAINER_FILES}"

# Execute
eval $DOCKER_CMD
