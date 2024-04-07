[![Open Source Helpers](https://www.codetriage.com/devsecopsbr/kubernetes/badges/users.svg)](https://www.codetriage.com/devsecopsbr/kubernetes)

# Welcome to the DevSecOps Pre-Commit Hooks Project

Welcome to our open-source project focused on automating DevSecOps practices through pre-commit hooks. This project is dedicated to streamlining daily tasks related to Kubernetes deployments, cluster sanitization, security scanning, and so on.

## Features

- **Kubernetes Deployment Hooks**: Validate Kubernetes YAML manifests to ensure correctness and adherence to best practices before deployment.
- **Cluster Sanitizer Hooks**: Perform checks to sanitize Kubernetes clusters, identifying potential misconfigurations and security vulnerabilities.
- **Security Scanning Hooks**: Integrate security scanning tools to identify vulnerabilities and weaknesses in your code and dependencies.
- **Linting Syntax Hooks**: Enforce coding standards and best practices by running linters on your codebase before committing.

## Getting Started

To start using our pre-commit hooks in your projects, follow these simple steps:

1. **Installation**: Install the pre-commit framework if you haven't already:

```shell
pip install pre-commit
```

2. **Configuration**: Add our pre-commit hooks to your project's `.pre-commit-config.yaml` file:

```yaml
default_stages: [pre-commit, pre-push]

repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: master
    hooks:
      - id: pluto_detect_files
        args: [ <your-charts-folder> ]
        verbose: true #optional
```

> Remember to setup your default_stages to have a better control on how trigger the hook

3. **Initialization**: Run `pre-commit install` to set up the hooks in your repository.
   1. Stay up to date run `pre-commit autoupdate` and don't miss improves, features, andfixes updates.

4. **Usage**:

Commit your changes as usual. Our pre-commit hooks will automatically run before each commit, checking for any issues or violations.

## Our hooks

- pluto detect-files
  - Search for kubernetes deprecated APIs in files

## Contributions

We welcome contributions from the community to help improve and expand the functionality of our pre-commit hooks. Whether it's adding support for new tools, improving existing hooks, or fixing bugs, your contributions are invaluable to making this project better for everyone.

To contribute, simply fork our repository, make your changes, and submit a pull request. Be sure to follow our contribution guidelines and code of conduct.

## Support

If you have any questions, feedback, or issues, please don't hesitate to reach out to us. You can open an issue on our GitHub repository, join our community discussions, or contact the maintainers directly.

Happy coding and stay secure with DevSecOpsOn Pre-Commit Hooks!