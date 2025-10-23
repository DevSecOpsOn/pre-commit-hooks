#!/usr/bin/env bash

# Good shell script for testing shellcheck

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    local name="${1:-World}"
    echo "Hello, ${name}!"
    
    if [[ -f "${SCRIPT_DIR}/config.txt" ]]; then
        echo "Config file found"
    fi
    
    return 0
}

main "$@"
