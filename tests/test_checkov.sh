#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Checkov ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if checkov is installed
if ! command -v checkov &> /dev/null; then
    echo -e "${RED}ERROR: checkov is not installed${NC}"
    echo "Install with: brew install checkov"
    echo "Or: pip install checkov"
    exit 1
fi

echo -e "${GREEN}✓ checkov is installed${NC}"
echo "checkov version: $(checkov --version 2>&1 | head -n 1)"
echo ""

# Test 1: Checkov scan on Kubernetes manifests
echo -e "${YELLOW}Test 1: Checkov scan on Kubernetes manifests${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/checkov/checkov_scan.sh" -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with issues found${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Test with directory scan
echo -e "${YELLOW}Test 2: Test with directory scan${NC}"
cd "$SCRIPT_DIR"
if bash "$HOOKS_DIR/checkov/checkov_scan.sh" -d fixtures; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with specific framework
echo -e "${YELLOW}Test 3: Test with Kubernetes framework${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/checkov/checkov_scan.sh" -f kubernetes -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Test with soft-fail
echo -e "${YELLOW}Test 4: Test with soft-fail mode${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/checkov/checkov_scan.sh" -s -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 5: Test with compact output
echo -e "${YELLOW}Test 5: Test with compact output${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/checkov/checkov_scan.sh" -c -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 5 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 5 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 6: Test with quiet mode
echo -e "${YELLOW}Test 6: Test with quiet mode${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/checkov/checkov_scan.sh" -q -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 6 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 6 completed (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== Checkov Tests Complete ===${NC}"
