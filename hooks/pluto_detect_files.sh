#!/usr/bin/env bash

set -eo pipefail

# global variables
declare -a ARGS=()
declare -a FILES=()
declare -a PARAMS="detect-files --output markdown"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/common.sh"

main() {

  initialize_
  parse_cmdline_ "$@"
  pluto_detect_files_ "$ARGS" "$FILES"

}

pluto_detect_files_() {

  for file_with_path in $FILES; do
    file_with_path="${file_with_path// /__REPLACED__SPACE__}"
    paths[index]=$(dirname "$file_with_path")
    let "index+=1"
  done

  for i in "${ARGS[@]}"
  do
   PARAMS="${PARAMS} ${i}"
  done

  echo $PARAMS

  for path_uniq in $(echo "${paths[*]}" | tr ' ' '\n' | sort -u); do
    path_uniq="${path_uniq//__REPLACED__SPACE__/ }"
    pushd "$path_uniq" > /dev/null
    pluto $PARAMS
    popd > /dev/null
  done

}

[[ ${BASH_SOURCE[0]} != "$0" ]] || main "$@"
