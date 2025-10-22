# Pre-Commit Hooks Test Suite

This directory contains comprehensive test cases for all pre-commit hooks.

## Prerequisites

### Required Tools

1. **Pluto** - `brew install FairwindsOps/tap/pluto`
2. **Nova** - `brew install FairwindsOps/tap/nova`
3. **Popeye** - `brew install derailed/popeye/popeye`
4. **kubectl** - `brew install kubectl`
5. **helm** - `brew install helm`

### Optional: Kubernetes Cluster

Some tests require an active cluster. Use minikube, kind, or Docker Desktop.

## Running Tests

### Run All Tests
```bash
cd tests
chmod +x *.sh
./run_all_tests.sh
```

### Run Individual Tests
```bash
./test_pluto_detect_files.sh    # No cluster required
./test_pluto_detect_helm.sh     # Requires cluster
./test_pluto_detect_api.sh      # Requires cluster
./test_nova_search_updates.sh   # Requires cluster
./test_popeye_scan.sh           # Requires cluster
```

## Test Coverage

- **Pluto**: Deprecated API detection in files, Helm, and cluster
- **Nova**: Outdated Helm chart detection
- **Popeye**: Cluster resource sanitization

## Exit Codes

- `0` - Success
- `1` - Warnings/issues found (expected for some tests)
- `>1` - Test failure
