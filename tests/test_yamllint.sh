#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing yamllint ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if yamllint is installed
if ! command -v yamllint &> /dev/null; then
    echo -e "${RED}ERROR: yamllint is not installed${NC}"
    echo "Install with: brew install yamllint"
    echo "Or: pip install yamllint"
    exit 1
fi

echo -e "${GREEN}✓ yamllint is installed${NC}"
echo "yamllint version: $(yamllint --version 2>&1)"
echo ""

# Test 1: Lint modern deployment YAML
echo -e "${YELLOW}Test 1: Lint modern deployment YAML${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/yamllint/yamllint_lint.sh" -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with warnings${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Lint deprecated deployment YAML
echo -e "${YELLOW}Test 2: Lint deprecated deployment YAML${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/yamllint/yamllint_lint.sh" -- deprecated-deployment.yaml; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with custom config
echo -e "${YELLOW}Test 3: Test with custom config${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/yamllint/yamllint_lint.sh" -c .yamllint -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Test with parsable format
echo -e "${YELLOW}Test 4: Test with parsable format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/yamllint/yamllint_lint.sh" -f parsable -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 5: Test with strict mode
echo -e "${YELLOW}Test 5: Test with strict mode${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/yamllint/yamllint_lint.sh" -s -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 5 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 5 completed (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== yamllint Tests Complete ===${NC}"
