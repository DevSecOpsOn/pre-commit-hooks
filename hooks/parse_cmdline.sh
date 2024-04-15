#!/usr/bin/env bash

set -eo pipefail

# global variables
declare -a ARGS=()
declare -a FILES=()

declare -a context namespace k8s_version format

pluto::detect_files_() {

  while getopts d:t files; do
    case $files in
      d | --directory)
        directory=${OPTARG}
        ARGS+=("$directory ")
      ;;
      t | --target-versions)
        k8s_version=${OPTARG}
        ARGS+=("$k8s_version ")
      ;;
      --)
        shift
        FILES+=("$@")
        break
        ;;
    esac
  done

}

pluto::detect_helm_() {

  while getopts k:nt helm; do
    case $helm in
      k | --kube-context)
        context=${OPTARG}
        ARGS+=("$context ")
      ;;
      n | --namespace)
        namespace=$OPTARG
        ARGS+=("$namespace ")
      ;;
      t | --target-versions)
        k8s_version=${OPTARG}
        ARGS+=("$k8s_version ")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

nova::search_updates_() {

  while getopts k:ndf nova; do
    case $nova in
      k | --kube-context)
        context=${OPTARG}
        ARGS+=("$context ")
      ;;
      n | --namespace)
        namespace=$OPTARG
        ARGS+=("$namespace ")
      ;;
      d | --target-versions)
        k8s_version=${OPTARG}
        ARGS+=("$k8s_version ")
      ;;
      f | --format)
        format=${OPTARG}
        ARGS+=("$format ")
      ;;
      --)
        shift
        # shellcheck disable=SC2034 # Variable is used
        FILES=("$@")
        break
      ;;
    esac
  done

}
