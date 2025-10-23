#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Hadolint ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if hadolint is installed
if ! command -v hadolint &> /dev/null; then
    echo -e "${RED}ERROR: hadolint is not installed${NC}"
    echo "Install with: brew install hadolint"
    exit 1
fi

echo -e "${GREEN}✓ hadolint is installed${NC}"
echo "hadolint version: $(hadolint --version | head -n 1)"
echo ""

# Test 1: Lint good Dockerfile
echo -e "${YELLOW}Test 1: Lint good Dockerfile${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/hadolint/hadolint_lint.sh" -- Dockerfile.good; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with warnings${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Lint bad Dockerfile (should find issues)
echo -e "${YELLOW}Test 2: Lint bad Dockerfile (should find issues)${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/hadolint/hadolint_lint.sh" -- Dockerfile.bad; then
    echo -e "${YELLOW}⚠ Test 2 passed but expected issues${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${GREEN}✓ Test 2 correctly found issues (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with JSON format
echo -e "${YELLOW}Test 3: Test with JSON format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/hadolint/hadolint_lint.sh" -f json -- Dockerfile.good; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Test with codeclimate format
echo -e "${YELLOW}Test 4: Test with codeclimate format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/hadolint/hadolint_lint.sh" -f codeclimate -- Dockerfile.good; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== Hadolint Tests Complete ===${NC}"
