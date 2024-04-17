#!/usr/bin/env bash

set -eo pipefail

# global variables
declare -a ARGS=()
declare -a FILES=()

declare -a context containers format k8s_version namespace removed score

pluto::detect_files_() {

  while getopts d:to files; do
    case $files in
      d | --directory)
        directory=${OPTARG}
        ARGS+=("$directory ")
      ;;
      t | --target-versions)
        k8s_version=${OPTARG}
        ARGS+=("$k8s_version ")
      ;;
      o | --output)
        format=${OPTARG}
        ARGS+=("$format ")
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

  while getopts k:nto helm; do
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
      o | --output)
        format=${OPTARG}
        ARGS+=("$format ")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

pluto::detect_api_() {

  while getopts o:rt api; do
    case $api in
      r | --only-show-removed)
        removed=${OPTARG}
        ARGS+=($"$removed ")
      ;;
      o | --output)
        format=${OPTARG}
        ARGS+=("$format ")
      ;;
      t | --target-versions)
        k8s_version=${OPTARG}
        ARGS+=("$k8s_version ")
      ;;
    esac
  done

}

nova::search_updates_() {

  while getopts k:cfanw nova; do
    case $nova in
      k | --context)
        context=${OPTARG}
        ARGS+=("$context ")
      ;;
      c | --containers)
        containers=${OPTARG}
        ARGS+=("$containers ")
      ;;
      f | --format)
        format=${OPTARG}
        ARGS+=("$format ")
      ;;
      a | --include-all)
        namespace=${OPTARG}
        ARGS+=("$namespace ")
      ;;
      n | --namespace)
        namespace=$OPTARG
        ARGS+=("$namespace ")
      ;;
      w | --wide)
        shift
        ARGS+=("$OPTARG ")
        shift
      ;;
    esac
  done

}

popeye::scan_resources_() {

  while getopts o:kAs popeye; do
    case $popeye in
      A | --all-namespaces)
        ARGS+=${OPTARG}
      ;;
      k | --context)
        ARGS+=${OPTARG}
      ;;
      s | --min-score)
        ARGS+=$OPTARG
      ;;
      o | --out)
        ARGS+=${OPTARG}
      ;;
      --save)
        ARGS+="$@ "
    esac
  done

}
