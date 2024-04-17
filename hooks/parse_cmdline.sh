#!/usr/bin/env bash

set -eo pipefail

# global variables
declare -a ARGS=()
declare -a FILES=()

declare -a context containers format k8s_version namespace removed score

pluto::detect_files_() {

  while getopts dto files; do
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

  while getopts knto helm; do
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

  while getopts ort api; do
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

  while getopts kcfanw nova; do
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

  while getopts o popeye; do
    case $popeye in
      --all-namespaces)
        namespace=${OPTARG}
        ARGS+=("$namespace ")
      ;;
      --context)
        context=${OPTARG}
        ARGS+=("$context ")
      ;;
      --min-score)
        score=$OPTARG
        ARGS+=("$score ")
      ;;
      o | --out)
        format=${OPTARG}
        ARGS+=("$format ")
      ;;
      --)
        ARGS+="$@ "
    esac
  done

}
