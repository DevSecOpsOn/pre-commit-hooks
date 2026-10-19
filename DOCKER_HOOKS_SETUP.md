# Docker-Based Pre-Commit Hooks Setup

This document describes the Docker-based approach for running DevSecOps pre-commit hooks without requiring local tool installations.

## Overview

The Docker-based hooks use containerized versions of security and linting tools, following DevOps/SRE best practices by:
- Using specific version tags (not `latest`) for reproducibility
- Eliminating the need for local tool installations
- Providing consistent environments across different systems
- Following container-first DevOps practices

## Docker Images Used

| Tool | Docker Image | Version | Purpose |
|------|--------------|---------|---------|
| gitleaks | zricethezav/gitleaks | v8.30.1 | Secret detection |
| hadolint | hadolint/hadolint | v2.14.0-alpine | Dockerfile linting |
| shellcheck | koalaman/shellcheck | v0.11.0 | Shell script analysis |
| yamllint | volkerraschek/yamllint | 1.38.0 | YAML validation |
| kubescore | zegl/kube-score | v1.20.0 | Kubernetes best practices |
| trivy | aquasec/trivy | 0.72.0 | Vulnerability scanning |
| checkov | bridgecrew/checkov | 3.3.7 | IaC security scanning |

## Files Created

### Docker Hook Wrapper Scripts
- `docker-hooks/gitleaks-docker.sh` - Wrapper for gitleaks secret detection
- `docker-hooks/hadolint-docker.sh` - Wrapper for hadolint Dockerfile linting
- `docker-hooks/shellcheck-docker.sh` - Wrapper for shellcheck shell script analysis
- `docker-hooks/yamllint-docker.sh` - Wrapper for yamllint YAML validation
- `docker-hooks/kubescore-docker.sh` - Wrapper for kube-score Kubernetes analysis
- `docker-hooks/trivy-docker.sh` - Wrapper for trivy vulnerability scanning
- `docker-hooks/checkov-docker.sh` - Wrapper for checkov IaC security scanning

### Configuration Files
- `.pre-commit-hooks-docker.yaml` - Hook definitions for Docker-based hooks
- `docker-compose.yml` - Docker Compose configuration for tool orchestration
- `local-test-case/.pre-commit-config-docker.yaml` - Local test configuration

## Usage

### Prerequisites

1. **Docker must be running**: The Docker daemon must be started before using these hooks
2. **Docker images**: Pull the required images:
   ```bash
   docker pull zricethezav/gitleaks:v8.30.1
   docker pull hadolint/hadolint:v2.14.0-alpine
   docker pull koalaman/shellcheck:v0.11.0
   docker pull volkerraschek/yamllint:1.38.0
   docker pull zegl/kube-score:v1.20.0
   docker pull aquasec/trivy:0.72.0
   docker pull bridgecrew/checkov:3.3.7
   ```

### Using Docker Compose

Start all tools with Docker Compose:
```bash
docker-compose up
```

This will pull and prepare all tool containers.

### Using with Pre-Commit

1. Copy the Docker-based configuration:
   ```bash
   cp .pre-commit-hooks-docker.yaml .pre-commit-hooks.yaml
   ```

2. Or use the local test configuration:
   ```bash
   cd local-test-case
   cp .pre-commit-config-docker.yaml .pre-commit-config.yaml
   pre-commit install
   ```

3. Run hooks:
   ```bash
   pre-commit run --all-files
   ```

## Testing

The local test case includes test files for each hook type:
- `k8s-manifests/` - Kubernetes YAML files
- `dockerfiles/` - Dockerfile examples (good and bad)
- `scripts/` - Shell scripts with issues
- `terraform/` - Terraform configurations

### Test Status

- ✅ **gitleaks-docker**: Tested and working
- ⏳ **hadolint-docker**: Script ready, requires Docker daemon
- ⏳ **shellcheck-docker**: Script ready, requires Docker daemon
- ⏳ **yamllint-docker**: Script ready, requires Docker daemon
- ⏳ **kubescore-docker**: Script ready, requires Docker daemon
- ⏳ **trivy-docker**: Script ready, requires Docker daemon
- ⏳ **checkov-docker**: Script ready, requires Docker daemon

## Benefits of Docker-Based Approach

1. **No Local Installation**: Eliminates the need to install multiple security tools locally
2. **Version Consistency**: Uses specific version tags for reproducible builds
3. **Environment Isolation**: Each tool runs in its own isolated container
4. **Cross-Platform**: Works consistently across macOS, Linux, and Windows
5. **Easy Updates**: Update versions by changing image tags in wrapper scripts
6. **DevOps Best Practices**: Follows container-first methodology

## Troubleshooting

### Docker Daemon Not Running

If you encounter:
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

Start Docker Desktop or the Docker daemon:
```bash
# macOS
open /Applications/Docker.app

# Linux
sudo systemctl start docker
```

### Permission Issues

If you encounter permission errors with volume mounts, ensure:
- The user running pre-commit has Docker permissions
- File paths are accessible to the Docker daemon

### Image Pull Issues

If images fail to pull:
- Check your internet connection
- Verify Docker Hub is accessible
- Check for rate limiting on Docker Hub

## Next Steps

1. Start Docker daemon
2. Pull all required Docker images
3. Test each hook individually
4. Update documentation with test results
5. Consider adding more Docker-based hooks for other tools

## Version Management

To update tool versions:
1. Update the image tag in the corresponding wrapper script
2. Pull the new image: `docker pull <image>:<new-version>`
3. Test the updated hook
4. Update this documentation

## Comparison: Native vs Docker

| Aspect | Native Installation | Docker-Based |
|--------|-------------------|--------------|
| Setup Time | High (install each tool) | Low (pull images) |
| Disk Space | Moderate | Higher (images) |
| Version Control | Manual per tool | Centralized in scripts |
| Consistency | Varies by system | High (containers) |
| Updates | Manual per tool | Centralized |
| DevOps Alignment | Low | High |
