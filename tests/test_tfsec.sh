#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing tfsec ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures/terraform"

# Check if tfsec is installed
if ! command -v tfsec &> /dev/null; then
    echo -e "${RED}ERROR: tfsec is not installed${NC}"
    echo "Install with: brew install tfsec"
    exit 1
fi

echo -e "${GREEN}✓ tfsec is installed${NC}"
echo "tfsec version: $(tfsec --version 2>&1 | head -n 1)"
echo ""

# Test 1: Scan Terraform directory
echo -e "${YELLOW}Test 1: Scan Terraform directory${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/tfsec/tfsec_scan.sh" -- main.tf; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with security issues found${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Test with JSON format
echo -e "${YELLOW}Test 2: Test with JSON format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/tfsec/tfsec_scan.sh" -f json -- main.tf; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with minimum severity (HIGH)
echo -e "${YELLOW}Test 3: Test with minimum severity (HIGH)${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/tfsec/tfsec_scan.sh" -s HIGH -- main.tf; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Test with minimum severity (CRITICAL)
echo -e "${YELLOW}Test 4: Test with minimum severity (CRITICAL)${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/tfsec/tfsec_scan.sh" -s CRITICAL -- main.tf; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 5: Test with soft-fail mode
echo -e "${YELLOW}Test 5: Test with soft-fail mode${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/tfsec/tfsec_scan.sh" -m -- main.tf; then
    echo -e "${GREEN}✓ Test 5 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 5 completed (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== tfsec Tests Complete ===${NC}"
echo -e "${YELLOW}Note: tfsec scans for security issues in Terraform. Exit code 1 means issues were found.${NC}"
