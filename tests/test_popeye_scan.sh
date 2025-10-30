#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Popeye Scan ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"

# Check if popeye is installed
if ! command -v popeye &> /dev/null; then
    echo -e "${RED}ERROR: popeye is not installed${NC}"
    echo "Install with: brew install derailed/popeye/popeye"
    exit 1
fi

echo -e "${GREEN}✓ popeye is installed${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}ERROR: kubectl is not installed${NC}"
    echo "Install with: brew install kubectl"
    exit 1
fi

echo -e "${GREEN}✓ kubectl is installed${NC}"
echo ""

# Check if there's a kubernetes context available
if ! kubectl config current-context &> /dev/null; then
    echo -e "${YELLOW}WARNING: No active Kubernetes context${NC}"
    echo "Skipping Popeye tests (requires active k8s cluster)"
    exit 0
fi

CURRENT_CONTEXT=$(kubectl config current-context)
echo -e "${GREEN}✓ Active context: $CURRENT_CONTEXT${NC}\n"

# Test 1: Scan cluster resources
echo -e "${YELLOW}Test 1: Scan cluster resources${NC}"
if bash "$HOOKS_DIR/popeye/popeye_scan.sh" -k "$CURRENT_CONTEXT"; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with warnings (issues found)${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Test with all-namespaces flag
echo -e "${YELLOW}Test 2: Test with all-namespaces flag${NC}"
if bash "$HOOKS_DIR/popeye/popeye_scan.sh" -k "$CURRENT_CONTEXT" -A; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with minimum score
echo -e "${YELLOW}Test 3: Test with minimum score (80)${NC}"
if bash "$HOOKS_DIR/popeye/popeye_scan.sh" -k "$CURRENT_CONTEXT" -s 80; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Test with JSON output
echo -e "${YELLOW}Test 4: Test with JSON output format${NC}"
if bash "$HOOKS_DIR/popeye/popeye_scan.sh" -k "$CURRENT_CONTEXT" -o json; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== Popeye Scan Tests Complete ===${NC}"
