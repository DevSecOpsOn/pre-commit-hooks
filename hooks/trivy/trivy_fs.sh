#!/usr/bin/env bash

set -eo pipefail

PARAMS="fs "

# Import external functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly INITIALIZE="$(cd "$SCRIPT_DIR/.." && pwd -P)"
readonly PARSE_CMD="$(cd "$SCRIPT_DIR/.." && pwd -P)"

source "$INITIALIZE/initialize.sh"
source "$PARSE_CMD/parse_cmdline.sh"

main() {

  initialize_
  trivy::fs_ "$@"
  trivy_fs_ "$ARGS" "$FILES"

}

trivy_fs_() {

  local -a paths=()
  local index=0
  local path_uniq="."

  # Extract directory paths from files
  for file_with_path in "${FILES[@]}"; do
    file_with_path="${file_with_path// /__REPLACED__SPACE__}"
    paths[index]=$(dirname "$file_with_path")
    ((index++))
  done

  # Get unique path (assuming all files are in same directory or use first)
  if [[ ${#paths[@]} -gt 0 ]]; then
    path_uniq="${paths[0]}"
  fi

  # Build parameters from ARGS array
  for i in "${ARGS[@]}"; do
    PARAMS="${PARAMS} ${i}"
  done

  # Add target path
  if [[ ${#FILES[@]} -gt 0 ]]; then
    PARAMS="${PARAMS} ${FILES[0]}"
  else
    PARAMS="${PARAMS} ."
  fi

  # Execute trivy fs command
  pushd "$path_uniq" > /dev/null
  echo "$PARAMS"
  trivy $PARAMS
  popd > /dev/null

}

[[ ${BASH_SOURCE[0]} != "$0" ]] || main "$@"
