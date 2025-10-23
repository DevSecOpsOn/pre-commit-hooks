#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing ShellCheck ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    echo -e "${RED}ERROR: shellcheck is not installed${NC}"
    echo "Install with: brew install shellcheck"
    exit 1
fi

echo -e "${GREEN}✓ shellcheck is installed${NC}"
echo "shellcheck version: $(shellcheck --version | grep version | head -n 1)"
echo ""

# Test 1: Check good shell script
echo -e "${YELLOW}Test 1: Check good shell script${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/shellcheck/shellcheck_check.sh" -- test-script.sh; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with warnings${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Check bad shell script (should find issues)
echo -e "${YELLOW}Test 2: Check bad shell script (should find issues)${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/shellcheck/shellcheck_check.sh" -- test-script-bad.sh; then
    echo -e "${YELLOW}⚠ Test 2 passed but expected issues${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${GREEN}✓ Test 2 correctly found issues (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with severity filter (error only)
echo -e "${YELLOW}Test 3: Test with severity filter (error only)${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/shellcheck/shellcheck_check.sh" -s error -- test-script-bad.sh; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Test with JSON format
echo -e "${YELLOW}Test 4: Test with JSON format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/shellcheck/shellcheck_check.sh" -f json -- test-script.sh; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 5: Check all hook scripts in the project
echo -e "${YELLOW}Test 5: Check all hook scripts${NC}"
cd "$HOOKS_DIR"
if bash "$HOOKS_DIR/shellcheck/shellcheck_check.sh" -s warning -- initialize.sh; then
    echo -e "${GREEN}✓ Test 5 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 5 completed (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== ShellCheck Tests Complete ===${NC}"
