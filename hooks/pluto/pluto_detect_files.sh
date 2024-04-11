#!/usr/bin/env bash

set -eo pipefail

PARAMS="detect-files -o markdown "

# Import external functions
readonly SCRIPT_DIR="$(cd .. "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "$SCRIPT_DIR/initialize.sh"
source "$SCRIPT_DIR/parse_cmdline.sh"

main() {

  initialize_
  pluto::detect_files_ "$@"
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
    pushd "$path_uniq" > /dev/null
    echo $PARAMS
    pluto $PARAMS
    popd > /dev/null
  done

}

[[ ${BASH_SOURCE[0]} != "$0" ]] || main "$@"
