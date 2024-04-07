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
  argv=$(getopt -n Pluto -o hi: --long help,directory,target-versions: -- "$@") || return
  eval "set -- $argv"

  for argv; do
    case $1 in
      -d | --directory)
        ARGS+=("$1")
        ARGS+=("$2")
        shift 2
        ;;
      -t | --target-versions)
        ARGS+=("$3")
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
