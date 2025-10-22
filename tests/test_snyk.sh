#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Snyk ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if snyk is installed
if ! command -v snyk &> /dev/null; then
    echo -e "${RED}ERROR: snyk is not installed${NC}"
    echo "Install with: brew install snyk/tap/snyk"
    echo "Then authenticate: snyk auth"
    exit 1
fi

echo -e "${GREEN}✓ snyk is installed${NC}"
echo "snyk version: $(snyk version 2>&1 | head -n 1)"
echo ""

# Check if authenticated
if ! snyk auth check &> /dev/null; then
    echo -e "${YELLOW}WARNING: Not authenticated with Snyk${NC}"
    echo "Run: snyk auth"
    echo "Skipping Snyk tests"
    exit 0
fi

echo -e "${GREEN}✓ Authenticated with Snyk${NC}\n"

# Test 1: Snyk IaC test on Kubernetes manifests
echo -e "${YELLOW}Test 1: Snyk IaC test on Kubernetes manifests${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/snyk/snyk_iac.sh" -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with issues found${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Test with severity threshold
echo -e "${YELLOW}Test 2: Test with severity threshold (high)${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/snyk/snyk_iac.sh" -s high -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with JSON output
echo -e "${YELLOW}Test 3: Test with JSON output${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/snyk/snyk_iac.sh" -j -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Snyk container test (if Docker is available)
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}Test 4: Snyk container test${NC}"
    if bash "$HOOKS_DIR/snyk/snyk_container.sh" -- nginx:latest; then
        echo -e "${GREEN}✓ Test 4 passed${NC}\n"
    else
        EXIT_CODE=$?
        echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
    fi
else
    echo -e "${YELLOW}⊘ Test 4 skipped (Docker not available)${NC}\n"
fi

echo -e "${GREEN}=== Snyk Tests Complete ===${NC}"
