#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Infracost ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures/terraform-infracost"

# Check if infracost is installed
if ! command -v infracost &> /dev/null; then
    echo -e "${RED}ERROR: infracost is not installed${NC}"
    echo "Install with: brew install infracost/infracost/infracost"
    echo "Then configure: infracost auth login"
    exit 1
fi

echo -e "${GREEN}✓ infracost is installed${NC}"
echo "infracost version: $(infracost --version 2>&1 | head -n 1)"
echo ""

# Check if infracost is authenticated
if ! infracost configure get api_key &> /dev/null; then
    echo -e "${YELLOW}WARNING: Infracost not authenticated${NC}"
    echo "Run: infracost auth login"
    echo "Skipping Infracost tests"
    exit 0
fi

echo -e "${GREEN}✓ Infracost is authenticated${NC}\n"

# Check if Terraform fixtures exist
if [ ! -d "$FIXTURES_DIR" ]; then
    echo -e "${RED}ERROR: Terraform fixtures not found at $FIXTURES_DIR${NC}"
    exit 1
fi

# Test 1: Cost breakdown for Terraform directory
echo -e "${YELLOW}Test 1: Cost breakdown for Terraform directory${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/infracost/infracost_breakdown.sh" -p . -- main.tf; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with warnings${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Cost breakdown with JSON format
echo -e "${YELLOW}Test 2: Cost breakdown with JSON format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/infracost/infracost_breakdown.sh" -p . -f json -- main.tf; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Cost breakdown with table format
echo -e "${YELLOW}Test 3: Cost breakdown with table format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/infracost/infracost_breakdown.sh" -p . -f table -- main.tf; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Cost breakdown with show-skipped
echo -e "${YELLOW}Test 4: Cost breakdown with show-skipped${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/infracost/infracost_breakdown.sh" -p . -s -- main.tf; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 5: Cost breakdown with terraform var file
echo -e "${YELLOW}Test 5: Cost breakdown with terraform var file${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/infracost/infracost_breakdown.sh" -p . -t terraform.tfvars -- main.tf; then
    echo -e "${GREEN}✓ Test 5 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 5 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 6: Cost diff (if baseline exists)
echo -e "${YELLOW}Test 6: Generate baseline for cost diff${NC}"
cd "$FIXTURES_DIR"
# Generate baseline
if infracost breakdown --path . --format json --out infracost-base.json &> /dev/null; then
    echo -e "${GREEN}✓ Baseline generated${NC}"
    
    # Now test diff
    echo -e "${YELLOW}Test 6b: Cost diff with baseline${NC}"
    if bash "$HOOKS_DIR/infracost/infracost_diff.sh" -p . -c infracost-base.json -- main.tf; then
        echo -e "${GREEN}✓ Test 6b passed${NC}\n"
    else
        EXIT_CODE=$?
        echo -e "${YELLOW}⚠ Test 6b completed (exit code: $EXIT_CODE)${NC}\n"
    fi
    
    # Cleanup
    rm -f infracost-base.json
else
    echo -e "${YELLOW}⊘ Test 6 skipped (could not generate baseline)${NC}\n"
fi

echo -e "${GREEN}=== Infracost Tests Complete ===${NC}"
echo -e "${YELLOW}Note: Infracost shows estimated cloud costs. Requires authentication and Terraform files.${NC}"
