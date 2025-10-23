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

kubescore::score_() {

  while getopts o:ev kubescore; do
    case $kubescore in
      o) # --output-format
        format=${OPTARG}
        ARGS+=("--output-format" "$format")
      ;;
      e) # --enable-optional-test
        ARGS+=("--enable-optional-test")
      ;;
      v) # --verbose
        ARGS+=("--verbose")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

snyk::test_() {

  while getopts s:jd snyk; do
    case $snyk in
      s) # --severity-threshold
        local severity=${OPTARG}
        ARGS+=("--severity-threshold=$severity")
      ;;
      j) # --json
        ARGS+=("--json")
      ;;
      d) # --all-projects
        ARGS+=("--all-projects")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

snyk::container_() {

  while getopts s:jf snyk_container; do
    case $snyk_container in
      s) # --severity-threshold
        local severity=${OPTARG}
        ARGS+=("--severity-threshold=$severity")
      ;;
      j) # --json
        ARGS+=("--json")
      ;;
      f) # --file
        local dockerfile=${OPTARG}
        ARGS+=("--file=$dockerfile")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

snyk::iac_() {

  while getopts s:jr snyk_iac; do
    case $snyk_iac in
      s) # --severity-threshold
        local severity=${OPTARG}
        ARGS+=("--severity-threshold=$severity")
      ;;
      j) # --json
        ARGS+=("--json")
      ;;
      r) # --report
        ARGS+=("--report")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

trivy::fs_() {

  while getopts s:f:e trivy_fs; do
    case $trivy_fs in
      s) # --severity
        local severity=${OPTARG}
        ARGS+=("--severity" "$severity")
      ;;
      f) # --format
        format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      e) # --exit-code
        local exit_code=${OPTARG}
        ARGS+=("--exit-code" "$exit_code")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

trivy::image_() {

  while getopts s:f:e trivy_image; do
    case $trivy_image in
      s) # --severity
        local severity=${OPTARG}
        ARGS+=("--severity" "$severity")
      ;;
      f) # --format
        format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      e) # --exit-code
        local exit_code=${OPTARG}
        ARGS+=("--exit-code" "$exit_code")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

checkov::scan_() {

  while getopts d:f:sqc checkov; do
    case $checkov in
      d) # --directory
        local directory=${OPTARG}
        ARGS+=("--directory" "$directory")
      ;;
      f) # --framework
        local framework=${OPTARG}
        ARGS+=("--framework" "$framework")
      ;;
      s) # --soft-fail
        ARGS+=("--soft-fail")
      ;;
      q) # --quiet
        ARGS+=("--quiet")
      ;;
      c) # --compact
        ARGS+=("--compact")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

gitleaks::detect_() {

  while getopts c:vfr gitleaks; do
    case $gitleaks in
      c) # --config
        local config=${OPTARG}
        ARGS+=("--config" "$config")
      ;;
      v) # --verbose
        ARGS+=("--verbose")
      ;;
      f) # --format
        local format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      r) # --report-path
        local report=${OPTARG}
        ARGS+=("--report-path" "$report")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

hadolint::lint_() {

  while getopts c:f:t hadolint; do
    case $hadolint in
      c) # --config
        local config=${OPTARG}
        ARGS+=("--config" "$config")
      ;;
      f) # --format
        local format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      t) # --trusted-registry
        local registry=${OPTARG}
        ARGS+=("--trusted-registry" "$registry")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

shellcheck::check_() {

  while getopts s:f:ex shellcheck_opts; do
    case $shellcheck_opts in
      s) # --severity
        local severity=${OPTARG}
        ARGS+=("--severity=$severity")
      ;;
      f) # --format
        local format=${OPTARG}
        ARGS+=("--format=$format")
      ;;
      e) # --external-sources
        ARGS+=("--external-sources")
      ;;
      x) # --exclude
        local exclude=${OPTARG}
        ARGS+=("--exclude=$exclude")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

yamllint::lint_() {

  while getopts c:f:sd yamllint_opts; do
    case $yamllint_opts in
      c) # --config-file
        local config=${OPTARG}
        ARGS+=("--config-file" "$config")
      ;;
      f) # --format
        local format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      s) # --strict
        ARGS+=("--strict")
      ;;
      d) # --config-data
        local config_data=${OPTARG}
        ARGS+=("--config-data" "$config_data")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

tfsec::scan_() {

  while getopts f:s:em tfsec_opts; do
    case $tfsec_opts in
      f) # --format
        local format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      s) # --minimum-severity
        local severity=${OPTARG}
        ARGS+=("--minimum-severity" "$severity")
      ;;
      e) # --exclude
        local exclude=${OPTARG}
        ARGS+=("--exclude" "$exclude")
      ;;
      m) # --soft-fail
        ARGS+=("--soft-fail")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

infracost::breakdown_() {

  while getopts p:f:cst infracost_opts; do
    case $infracost_opts in
      p) # --path
        local path=${OPTARG}
        ARGS+=("--path" "$path")
      ;;
      f) # --format
        local format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      c) # --compare-to
        local compare=${OPTARG}
        ARGS+=("--compare-to" "$compare")
      ;;
      s) # --show-skipped
        ARGS+=("--show-skipped")
      ;;
      t) # --terraform-var-file
        local tfvars=${OPTARG}
        ARGS+=("--terraform-var-file" "$tfvars")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}

infracost::diff_() {

  while getopts p:f:cs infracost_diff; do
    case $infracost_diff in
      p) # --path
        local path=${OPTARG}
        ARGS+=("--path" "$path")
      ;;
      f) # --format
        local format=${OPTARG}
        ARGS+=("--format" "$format")
      ;;
      c) # --compare-to
        local compare=${OPTARG}
        ARGS+=("--compare-to" "$compare")
      ;;
      s) # --show-skipped
        ARGS+=("--show-skipped")
      ;;
      --)
        shift
        FILES=("$@")
        break
      ;;
    esac
  done

}
