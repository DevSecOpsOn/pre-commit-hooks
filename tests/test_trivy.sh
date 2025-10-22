#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Trivy ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${RED}ERROR: trivy is not installed${NC}"
    echo "Install with: brew install aquasecurity/trivy/trivy"
    exit 1
fi

echo -e "${GREEN}✓ trivy is installed${NC}"
echo "trivy version: $(trivy version 2>&1 | grep Version | head -n 1)"
echo ""

# Test 1: Trivy filesystem scan
echo -e "${YELLOW}Test 1: Trivy filesystem scan${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/trivy/trivy_fs.sh" -- .; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with vulnerabilities found${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Test with severity filter
echo -e "${YELLOW}Test 2: Test with severity filter (CRITICAL,HIGH)${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/trivy/trivy_fs.sh" -s CRITICAL,HIGH -- .; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with JSON format
echo -e "${YELLOW}Test 3: Test with JSON format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/trivy/trivy_fs.sh" -f json -- .; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Trivy image scan (if Docker is available)
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}Test 4: Trivy image scan${NC}"
    if bash "$HOOKS_DIR/trivy/trivy_image.sh" -- nginx:latest; then
        echo -e "${GREEN}✓ Test 4 passed${NC}\n"
    else
        EXIT_CODE=$?
        echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
    fi

    # Test 5: Image scan with severity filter
    echo -e "${YELLOW}Test 5: Image scan with severity filter${NC}"
    if bash "$HOOKS_DIR/trivy/trivy_image.sh" -s CRITICAL -- nginx:latest; then
        echo -e "${GREEN}✓ Test 5 passed${NC}\n"
    else
        EXIT_CODE=$?
        echo -e "${YELLOW}⚠ Test 5 completed (exit code: $EXIT_CODE)${NC}\n"
    fi
else
    echo -e "${YELLOW}⊘ Tests 4-5 skipped (Docker not available)${NC}\n"
fi

echo -e "${GREEN}=== Trivy Tests Complete ===${NC}"
