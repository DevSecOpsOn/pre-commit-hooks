#!/usr/bin/env bash

set -eo pipefail

PARAMS="test "

# Import external functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly INITIALIZE="$(cd "$SCRIPT_DIR/.." && pwd -P)"
readonly PARSE_CMD="$(cd "$SCRIPT_DIR/.." && pwd -P)"

source "$INITIALIZE/initialize.sh"
source "$PARSE_CMD/parse_cmdline.sh"

main() {

  initialize_
  snyk::test_ "$@"
  snyk_test_ "$ARGS" "$FILES"

}

snyk_test_() {

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

  # Execute snyk test command
  pushd "$path_uniq" > /dev/null
  echo "$PARAMS"
  snyk $PARAMS
  popd > /dev/null

}

[[ ${BASH_SOURCE[0]} != "$0" ]] || main "$@"
