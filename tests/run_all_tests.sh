#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Pre-Commit Hooks Test Suite                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

run_test() {
    local test_script=$1
    local test_name=$(basename "$test_script" .sh)
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Running: $test_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if bash "$test_script"; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓ $test_name PASSED${NC}\n"
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]; then
            SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
            echo -e "${YELLOW}⊘ $test_name SKIPPED${NC}\n"
        else
            FAILED_TESTS=$((FAILED_TESTS + 1))
            echo -e "${RED}✗ $test_name FAILED${NC}\n"
        fi
    fi
}

# Run all test scripts
echo -e "${YELLOW}Starting test execution...${NC}\n"

# Pluto tests
if [ -f "$SCRIPT_DIR/test_pluto_detect_files.sh" ]; then
    run_test "$SCRIPT_DIR/test_pluto_detect_files.sh"
fi

if [ -f "$SCRIPT_DIR/test_pluto_detect_helm.sh" ]; then
    run_test "$SCRIPT_DIR/test_pluto_detect_helm.sh"
fi

if [ -f "$SCRIPT_DIR/test_pluto_detect_api.sh" ]; then
    run_test "$SCRIPT_DIR/test_pluto_detect_api.sh"
fi

# Nova tests
if [ -f "$SCRIPT_DIR/test_nova_search_updates.sh" ]; then
    run_test "$SCRIPT_DIR/test_nova_search_updates.sh"
fi

# Popeye tests
if [ -f "$SCRIPT_DIR/test_popeye_scan.sh" ]; then
    run_test "$SCRIPT_DIR/test_popeye_scan.sh"
fi

# Print summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Test Summary                                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total Tests:   ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed:        ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:        ${RED}$FAILED_TESTS${NC}"
echo -e "Skipped:       ${YELLOW}$SKIPPED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review the output above.${NC}"
    exit 1
fi
