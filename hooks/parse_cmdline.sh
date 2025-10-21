#!/usr/bin/env bash

set -eo pipefail

# global variables
declare -a ARGS=()
declare -a FILES=()

declare -a context containers format k8s_version namespace removed score wide

pluto::detect_files_() {

  while getopts d:t:o: files; do
    case $files in
      d) # --directory
        directory=${OPTARG}
        ARGS+=("--directory" "$directory")
      ;;
      t) # --target-versions
        k8s_version=${OPTARG}
        ARGS+=("--target-versions" "$k8s_version")
      ;;
      o) # --output
        format=${OPTARG}
        ARGS+=("--output" "$format")
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

  while getopts k:n:t:o: helm; do
    case $helm in
      k) # --kube-context
        context=${OPTARG}
        ARGS+=("--kube-context" "$context")
      ;;
      n) # --namespace
        namespace=$OPTARG
        ARGS+=("--namespace" "$namespace")
      ;;
      t) # --target-versions
        k8s_version=${OPTARG}
        ARGS+=("--target-versions" "$k8s_version")
      ;;
      o) # --output
        format=${OPTARG}
        ARGS+=("--output" "$format")
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

  while getopts o:rt: api; do
    case $api in
      o) # --output
        format=${OPTARG}
        ARGS+=("--output" "$format")
      ;;
      r) # --only-show-removed
        ARGS+=("--only-show-removed")
      ;;
      t) # --target-versions
        k8s_version=${OPTARG}
        ARGS+=("--target-versions" "$k8s_version")
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

  while getopts k:c:f:an:w nova; do
    case $nova in
      k) # --context
        context=${OPTARG}
        ARGS+=("--context" "$context")
      ;;
      c) # --containers
        containers=${OPTARG}
        ARGS+=("--containers" "$containers")
      ;;
      f) # --format
        format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      a) # --include-all
        ARGS+=("--include-all")
      ;;
      n) # --namespace
        namespace=$OPTARG
        ARGS+=("--namespace" "$namespace")
      ;;
      w) # --wide
        ARGS+=("--wide")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

popeye::scan_resources_() {

  while getopts k:o:As: popeye; do
    case $popeye in
      k) # --context
        context=${OPTARG}
        ARGS+=("--context" "$context")
      ;;
      A) # --all-namespaces
        ARGS+=("--all-namespaces")
      ;;
      s) # --min-score
        score=$OPTARG
        ARGS+=("--min-score" "$score")
      ;;
      o) # --out
        format=${OPTARG}
        ARGS+=("--out" "$format")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}
