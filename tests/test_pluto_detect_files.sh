#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Pluto Detect Files ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if pluto is installed
if ! command -v pluto &> /dev/null; then
    echo -e "${RED}ERROR: pluto is not installed${NC}"
    echo "Install with: brew install FairwindsOps/tap/pluto"
    exit 1
fi

echo -e "${GREEN}✓ pluto is installed${NC}"
echo "pluto version: $(pluto version 2>&1 | head -n 1)"
echo ""

# Test 1: Detect deprecated APIs in test files
echo -e "${YELLOW}Test 1: Detect deprecated APIs in fixtures${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/pluto/pluto_detect_files.sh" -d . -o wide; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    echo -e "${RED}✗ Test 1 failed (exit code: $?)${NC}\n"
fi

# Test 2: Test with specific file
echo -e "${YELLOW}Test 2: Detect deprecated APIs in specific file${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/pluto/pluto_detect_files.sh" -d . -- deprecated-deployment.yaml; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    echo -e "${RED}✗ Test 2 failed (exit code: $?)${NC}\n"
fi

# Test 3: Test with target version
echo -e "${YELLOW}Test 3: Test with target Kubernetes version${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/pluto/pluto_detect_files.sh" -d . -t v1.16.0; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    echo -e "${RED}✗ Test 3 failed (exit code: $?)${NC}\n"
fi

# Test 4: Test with JSON output
echo -e "${YELLOW}Test 4: Test with JSON output format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/pluto/pluto_detect_files.sh" -d . -o json; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    echo -e "${RED}✗ Test 4 failed (exit code: $?)${NC}\n"
fi

echo -e "${GREEN}=== Pluto Detect Files Tests Complete ===${NC}"
