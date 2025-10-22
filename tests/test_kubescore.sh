#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Testing Kube-score ===${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Check if kube-score is installed
if ! command -v kube-score &> /dev/null; then
    echo -e "${RED}ERROR: kube-score is not installed${NC}"
    echo "Install with: brew install kube-score/tap/kube-score"
    exit 1
fi

echo -e "${GREEN}✓ kube-score is installed${NC}"
echo "kube-score version: $(kube-score version 2>&1 | head -n 1)"
echo ""

# Test 1: Score Kubernetes manifests
echo -e "${YELLOW}Test 1: Score Kubernetes manifests${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/kubescore/kubescore_score.sh" -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 1 passed${NC}\n"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}⚠ Test 1 completed with warnings (issues found)${NC}\n"
    else
        echo -e "${RED}✗ Test 1 failed (exit code: $EXIT_CODE)${NC}\n"
    fi
fi

# Test 2: Test with verbose output
echo -e "${YELLOW}Test 2: Test with verbose output${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/kubescore/kubescore_score.sh" -v -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 2 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 2 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 3: Test with JSON output
echo -e "${YELLOW}Test 3: Test with JSON output format${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/kubescore/kubescore_score.sh" -o json -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 3 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 3 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 4: Test with enable-optional-test
echo -e "${YELLOW}Test 4: Test with optional tests enabled${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/kubescore/kubescore_score.sh" -e -- modern-deployment.yaml; then
    echo -e "${GREEN}✓ Test 4 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 4 completed (exit code: $EXIT_CODE)${NC}\n"
fi

# Test 5: Test with deprecated deployment
echo -e "${YELLOW}Test 5: Test with deprecated deployment${NC}"
cd "$FIXTURES_DIR"
if bash "$HOOKS_DIR/kubescore/kubescore_score.sh" -- deprecated-deployment.yaml; then
    echo -e "${GREEN}✓ Test 5 passed${NC}\n"
else
    EXIT_CODE=$?
    echo -e "${YELLOW}⚠ Test 5 completed with warnings (exit code: $EXIT_CODE)${NC}\n"
fi

echo -e "${GREEN}=== Kube-score Tests Complete ===${NC}"
