# Welcome to the DevSecOpsOn Pre-Commit Hooks Project

[![Open Source Helpers](https://www.codetriage.com/devsecopsbr/kubernetes/badges/users.svg)](https://www.codetriage.com/devsecopsbr/kubernetes)

Welcome to our open-source project focused on automating DevSecOps practices through pre-commit hooks. This project is dedicated to streamlining daily tasks related to Kubernetes deployments, cluster sanitization, security scanning, and so on.

## Features

- **Kubernetes Deployment Hooks**: Validate Kubernetes YAML manifests to ensure correctness and adherence to best practices before deployment.
- **Cluster Sanitizer Hooks**: Perform checks to sanitize Kubernetes clusters, identifying potential misconfigurations and security vulnerabilities.
- **Security Scanning Hooks**: Integrate security scanning tools to identify vulnerabilities and weaknesses in your code and dependencies.
- **Linting Syntax Hooks**: Enforce coding standards and best practices by running linters on your codebase before committing.
- **Docker-Based Hooks**: Run all security and linting tools in Docker containers without local installation, following DevOps/SRE best practices.

## Getting Started

To start using our pre-commit hooks in your projects, follow these simple steps:

**Installation**: Install the pre-commit framework if you haven't already:

```shell
pip install pre-commit
```

### Option 1: Docker-Based Hooks (Recommended)

The Docker-based approach eliminates the need for local tool installation and follows DevOps/SRE best practices by using specific version tags for reproducibility.

**Prerequisites**: Docker must be installed and running

**Setup**:

1. Pull required Docker images:
```shell
docker pull zricethezav/gitleaks:v8.30.1
docker pull hadolint/hadolint:v2.14.0-alpine
docker pull koalaman/shellcheck:v0.11.0
docker pull volkerraschek/yamllint:1.38.0
docker pull zegl/kube-score:v1.20.0
docker pull aquasec/trivy:0.72.0
docker pull bridgecrew/checkov:3.3.7
```

2. Add Docker-based hooks to your `.pre-commit-config.yaml`:

```yaml
default_stages: [pre-commit, pre-push]

repos:
  - repo: local
    hooks:
      - id: gitleaks-docker
        name: gitleaks-docker
        entry: docker-hooks/gitleaks-docker.sh
        language: script
        pass_filenames: true
        args: ['--source']
      - id: hadolint-docker
        name: hadolint-docker
        entry: docker-hooks/hadolint-docker.sh
        language: script
        files: 'dockerfiles/.*'
        pass_filenames: true
      - id: shellcheck-docker
        name: shellcheck-docker
        entry: docker-hooks/shellcheck-docker.sh
        language: script
        files: \.sh$
        pass_filenames: true
      - id: yamllint-docker
        name: yamllint-docker
        entry: docker-hooks/yamllint-docker.sh
        language: script
        files: (\.yml|\.yaml)$
        pass_filenames: true
        args: ['-s']
```

For detailed Docker setup instructions, see [DOCKER_HOOKS_SETUP.md](DOCKER_HOOKS_SETUP.md).

### Option 2: Native Installation

Install tools locally and use native hooks:

**Configuration**: Add our pre-commit hooks to your project's `.pre-commit-config.yaml` file:

```yaml
default_stages: [pre-commit, pre-push]

repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: master
    hooks:
      - id: pluto_detect_files
        args: [ -d helm_charts --output markdown ]
      - id: pluto_detect_helm
        args: [ -k <cluster-context> -o markdown ]
        verbose: true
      - id: pluto_detect_api
        args: [ -o markdown ]
        verbose: true
      - id: nova_search_updates
        args: [ -k <cluster-context> --format table --wide ]
        verbose: true
      - id: popeye_scan
        args: [ -k <cluster-context> ]
        verbose: true
```

> Remember to setup your default_stages to have a better control on how trigger the hook

1. **Initialization**: Run `pre-commit install --install-hooks` to set up the hooks in your repository.
   1. Stay up to date run `pre-commit autoupdate` and don't miss improves, features, andfixes updates.

2. **Usage**:

Commit your changes as usual. Our pre-commit hooks will automatically run before each commit, checking for any issues or violations.

## Our hooks

### Kubernetes Hooks

- pluto detect-files
  - Detect Kubernetes apiVersions in a directory
- pluto detect-helm
  - Detect Kubernetes apiVersions in a helm release (in cluster)
- pluto detect-api-resources
  - Detect Kubernetes apiVersions from an active cluster
- nova
  - A tool to check for updated chart releases
- popeye
  - Scans your Kubernetes clusters and reports potential resource issues

### Docker-Based Hooks

- gitleaks-docker
  - Detect hardcoded secrets and credentials (v8.30.1)
- hadolint-docker
  - Lint Dockerfiles for best practices and security (v2.14.0-alpine)
- shellcheck-docker
  - Static analysis for shell scripts (v0.11.0)
- yamllint-docker
  - Lint YAML files for syntax and style (1.38.0)
- kubescore-docker
  - Static code analysis for Kubernetes object definitions (v1.20.0)
- trivy-fs-docker
  - Scan filesystem for vulnerabilities (0.72.0)
- checkov-docker
  - Scan Infrastructure as Code for security and compliance (3.3.7)

### Additional Security Hooks

- snyk
  - Scan for vulnerabilities in dependencies and code
- trivy
  - Comprehensive vulnerability scanner for containers and filesystems
- checkov
  - Infrastructure as Code security and compliance scanner
- gitleaks
  - Detect hardcoded secrets and credentials
- hadolint
  - Dockerfile linting for best practices
- shellcheck
  - Shell script static analysis
- yamllint
  - YAML linting and validation
- tfsec
  - Terraform security scanner
- infracost
  - Infrastructure cost estimation

## Contributions

We welcome contributions from the community to help improve and expand the functionality of our pre-commit hooks. Whether it's adding support for new tools, improving existing hooks, or fixing bugs, your contributions are invaluable to making this project better for everyone.

To contribute, simply fork our repository, make your changes, and submit a pull request. Be sure to follow our contribution guidelines and code of conduct.

## Documentation

- [DOCKER_HOOKS_SETUP.md](DOCKER_HOOKS_SETUP.md) - Comprehensive guide for Docker-based hooks setup
- [DEVSECOPS_HOOKS.md](DEVSECOPS_HOOKS.md) - Detailed guide for all DevSecOps hooks
- [ESSENTIAL_HOOKS.md](ESSENTIAL_HOOKS.md) - Quick start guide for top 5 critical hooks
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Project architecture and overview

## Docker vs Native Installation

| Aspect | Docker-Based | Native Installation |
|--------|-------------|-------------------|
| Setup Time | Low (pull images) | High (install each tool) |
| Version Control | Centralized in scripts | Manual per tool |
| Consistency | High (containers) | Varies by system |
| DevOps Alignment | High | Low |
| Local Installation | Not required | Required |

## Testing

A local test case is available in the `local-test-case/` directory to validate hooks functionality:

```shell
cd local-test-case
pre-commit run --all-files
```

See [DOCKER_TEST_RESULTS.md](local-test-case/DOCKER_TEST_RESULTS.md) for detailed test results.

## Support

If you have any questions, feedback, or issues, please don't hesitate to reach out to us. You can open an issue on our GitHub repository, join our community discussions, or contact the maintainers directly.

Happy coding and stay secure with DevSecOpsOn Pre-Commit Hooks!
