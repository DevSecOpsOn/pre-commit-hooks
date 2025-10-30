#!/usr/bin/env bash

set -eo pipefail

PARAMS="diff "

# Import external functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly INITIALIZE="$(cd "$SCRIPT_DIR/.." && pwd -P)"
readonly PARSE_CMD="$(cd "$SCRIPT_DIR/.." && pwd -P)"

source "$INITIALIZE/initialize.sh"
source "$PARSE_CMD/parse_cmdline.sh"

main() {

  initialize_
  infracost::diff_ "$@"
  infracost_diff_ "$ARGS" "$FILES"

}

infracost_diff_() {

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

  # If no --path specified, use current directory or detected path
  if [[ ! "$PARAMS" =~ "--path" ]]; then
    if [[ ${#FILES[@]} -gt 0 ]]; then
      PARAMS="${PARAMS} --path ${path_uniq}"
    else
      PARAMS="${PARAMS} --path ."
    fi
  fi

  # Execute infracost diff command
  pushd "$path_uniq" > /dev/null
  echo "$PARAMS"
  infracost $PARAMS
  popd > /dev/null

}

[[ ${BASH_SOURCE[0]} != "$0" ]] || main "$@"
