#!/usr/bin/env bash
set -eo pipefail

# global variables
declare -a ARGS=()
declare -a FILES=()
declare -a PARAMS="detect-files --output markdown"

main() {

  initialize_
  parse_cmdline_ "$@"
  pluto_detect_files_ "$ARGS" "$FILES"

}

initialize_() {

  local dir
  local source
  source="${BASH_SOURCE[0]}"

  while [[ -L $source ]]; do
    dir="$(cd -P "$(dirname "$source")" > /dev/null && pwd)"
    source="$(readlink "$source")"
    [[ $source != /* ]] && source="$dir/$source"
  done
  _SCRIPT_DIR="$(dirname "$source")"

  # https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#index-getopts
  # source getopt function and shellcheck source=lib_getopt
  . "$_SCRIPT_DIR/lib_getopt"

}

parse_cmdline_() {
  declare argv
  argv=$(getopt -n Pluto -o hi: --long help,directory: -- "$@") || return
  eval "set -- $argv"

  for argv; do
    case $1 in
      -d | --directory)
        ARGS+=("$1")
        ARGS+=("$2")
        shift 2
        ;;
      --)
        shift
        FILES+=("$@")
        break
        ;;
     *)
        shift
    esac
  done

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
