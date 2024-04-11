#!/usr/bin/env bash

set -eo pipefail

declare -a ARGS=()
declare -a FILES=()

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
  source "$_SCRIPT_DIR/lib_getopt"

}
