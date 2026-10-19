# Local Test Case for Pre-Commit Hooks

This directory contains test files to validate the pre-commit hooks locally.

## Test Structure

```
local-test-case/
├── k8s-manifests/
│   ├── deprecated-deployment.yaml  # Contains deprecated API versions
│   └── modern-deployment.yaml      # Follows best practices
├── dockerfiles/
│   ├── Dockerfile.bad              # Has security issues
│   └── Dockerfile.good             # Follows best practices
├── scripts/
│   └── test-script.sh              # Shell script with issues
├── terraform/
│   └── main.tf                     # Terraform with security issues
└── .pre-commit-config.yaml         # Pre-commit configuration
```

## Available Tools on System

Currently installed:
- ✅ pluto - Available at /opt/homebrew/bin/pluto

Not installed (hooks will skip if tools missing):
- ❌ gitleaks
- ❌ hadolint
- ❌ shellcheck
- ❌ yamllint
- ❌ kubescore
- ❌ snyk
- ❌ trivy
- ❌ checkov
- ❌ tfsec

## Running Tests

### 1. Initialize git repository (required for pre-commit)
```bash
cd local-test-case
git init
git add .
```

### 2. Install pre-commit (if not already installed)
```bash
pip install pre-commit
```

### 3. Run hooks manually
```bash
# Run on all files
pre-commit run --all-files

# Run on specific files
pre-commit run --files k8s-manifests/deprecated-deployment.yaml
```

### 4. Test specific hook directly
```bash
# Test pluto directly
../hooks/pluto/pluto_detect_files.sh -d k8s-manifests --output markdown
```

## Expected Results

### pluto-detect-files
- **deprecated-api-deployment.yaml**: ✅ Should detect deprecated API versions (extensions/v1beta1)
- **modern-deployment.yaml**: ✅ Should pass (uses current apps/v1)
- **deprecated-deployment.yaml**: ✅ Should pass (uses current apps/v1)

### Other hooks
- Will skip gracefully if tools are not installed
- Can install tools individually to test specific hooks

## Actual Test Results

### ✅ Pluto Hook - WORKING
- Successfully detected deprecated `extensions/v1beta1` API
- Exit code 3 (expected for deprecated/removed APIs)
- Clear output with replacement information
- Integrates properly with pre-commit

### ❌ Other Hooks - NOT TESTED
- Tools not installed on system
- Hooks would work once tools are available
- See TEST_RESULTS.md for detailed findings

## Installing Missing Tools

```bash
# Essential tools
brew install gitleaks hadolint shellcheck yamllint

# Kubernetes tools
brew install kube-score/tap/kube-score

# Security tools
brew install aquasecurity/trivy/trivy checkov

# Terraform tools
brew install tfsec
```

## Test Scenarios

1. **Deprecated API Detection**: Test pluto with deprecated-deployment.yaml
2. **Best Practices Validation**: Test kubescore with modern-deployment.yaml
3. **Security Scanning**: Test with installed security tools
4. **Code Quality**: Test shellcheck, yamllint, hadolint when installed
