#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Gitleaks ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if gitleaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo -e "${RED}ERROR: gitleaks is not installed${NC}"
    echo "Install with: brew install gitleaks"
    exit 1
fi

echo -e "${GREEN}✓ gitleaks is installed${NC}"
echo "gitleaks version: $(gitleaks version 2>&1 | head -n 1)"
echo ""

# Test 1: Scan fixtures directory for secrets
echo -e "${YELLOW}Test 1: Scan directory for secrets${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/gitleaks/gitleaks_detect.sh" -- .; then
    echo -e "${GREEN}✓ Test 1 passed (no secrets found)${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with secrets detected${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Test with verbose output
echo -e "${YELLOW}Test 2: Test with verbose output${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/gitleaks/gitleaks_detect.sh" -v -- .; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with JSON format
echo -e "${YELLOW}Test 3: Test with JSON format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/gitleaks/gitleaks_detect.sh" -f json -- .; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Scan entire repository
echo -e "${YELLOW}Test 4: Scan entire repository${NC}"
cd "$SCRIPT_DIR/.."
if bash "$HOOKS_DIR/gitleaks/gitleaks_detect.sh" -- .; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== Gitleaks Tests Complete ===${NC}"
echo -e "${YELLOW}Note: Gitleaks scans for secrets in code. Exit code 1 means secrets were found.${NC}"
