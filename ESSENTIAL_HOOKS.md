# Essential DevSecOps Hooks - Quick Start Guide

The 5 most critical hooks for daily DevSecOps work.

## 🔐 1. Gitleaks - Secret Detection

**Critical Priority** - Prevents credential leaks

### Installation
```bash
brew install gitleaks
```

### Hook Configuration
```yaml
- id: gitleaks_detect
  name: Gitleaks - Secret Scanner
```

### Usage Examples
```bash
# Basic scan
gitleaks detect --source=.

# With verbose output
gitleaks detect --source=. --verbose

# JSON output
gitleaks detect --source=. --format=json

# With custom config
gitleaks detect --source=. --config=.gitleaks.toml
```

### Flags
- `-v` - Verbose output
- `-f <format>` - Output format (json, sarif, csv)
- `-c <config>` - Custom configuration file
- `-r <path>` - Report output path

### What It Detects
- API keys and tokens
- AWS credentials
- Private keys
- Database passwords
- OAuth tokens
- Generic high-entropy strings

### Exit Codes
- `0` - No secrets found
- `1` - Secrets detected
- `2` - Error occurred

---

## 🐳 2. Hadolint - Dockerfile Linter

**High Priority** - Container security and optimization

### Installation
```bash
brew install hadolint
```

### Hook Configuration
```yaml
- id: hadolint_lint
  files: (Dockerfile|\.dockerfile)$
```

### Usage Examples
```bash
# Basic lint
hadolint Dockerfile

# JSON format
hadolint --format=json Dockerfile

# Ignore specific rules
hadolint --ignore DL3008 Dockerfile

# With trusted registry
hadolint --trusted-registry docker.io Dockerfile
```

### Flags
- `-f <format>` - Output format (tty, json, checkstyle, codeclimate, gitlab_codeclimate, gnu, codacy, sonarqube, sarif)
- `-c <config>` - Configuration file
- `-t <registry>` - Trusted registry

### Common Issues Detected
- Using `latest` tag
- Running as root user
- Not pinning package versions
- Missing healthchecks
- Inefficient layer caching
- Security vulnerabilities

---

## 🐚 3. ShellCheck - Shell Script Analysis

**High Priority** - Prevent bash script bugs

### Installation
```bash
brew install shellcheck
```

### Hook Configuration
```yaml
- id: shellcheck_check
  files: \.sh$
```

### Usage Examples
```bash
# Basic check
shellcheck script.sh

# Severity filter (error only)
shellcheck --severity=error script.sh

# JSON format
shellcheck --format=json script.sh

# Exclude specific checks
shellcheck --exclude=SC2086 script.sh

# Check external sources
shellcheck --external-sources script.sh
```

### Flags
- `-s <severity>` - Minimum severity (error, warning, info, style)
- `-f <format>` - Output format (tty, json, gcc, checkstyle, diff, quiet)
- `-e` - Enable external sources
- `-x <code>` - Exclude specific check codes

### Common Issues Detected
- Unquoted variables
- Incorrect conditionals
- Missing error handling
- Deprecated syntax
- Potential command injection
- Logic errors

---

## 📄 4. yamllint - YAML Validation

**Medium Priority** - Prevent YAML syntax errors

### Installation
```bash
brew install yamllint
# or
pip install yamllint
```

### Hook Configuration
```yaml
- id: yamllint_lint
  files: (\.yml|\.yaml)$
```

### Usage Examples
```bash
# Basic lint
yamllint file.yaml

# With custom config
yamllint -c .yamllint file.yaml

# Strict mode
yamllint --strict file.yaml

# Parsable format (for CI)
yamllint --format=parsable file.yaml

# JSON format
yamllint --format=json file.yaml
```

### Flags
- `-c <file>` - Configuration file
- `-f <format>` - Output format (parsable, standard, colored, github, auto, json)
- `-s` - Strict mode (return non-zero for warnings)
- `-d <data>` - Inline configuration

### Configuration Example (.yamllint)
```yaml
extends: default

rules:
  line-length:
    max: 120
    level: warning
  indentation:
    spaces: 2
  comments:
    min-spaces-from-content: 1
  document-start: disable
```

### Common Issues Detected
- Syntax errors
- Indentation problems
- Line length violations
- Trailing spaces
- Missing document start
- Duplicate keys

---

## 🔒 5. tfsec - Terraform Security

**High Priority** - Terraform security scanning

### Installation
```bash
brew install tfsec
```

### Hook Configuration
```yaml
- id: tfsec_scan
  files: \.tf$
```

### Usage Examples
```bash
# Basic scan
tfsec .

# JSON format
tfsec --format=json .

# Minimum severity
tfsec --minimum-severity=HIGH .

# Exclude specific checks
tfsec --exclude=aws-s3-enable-bucket-encryption .

# Soft fail (always exit 0)
tfsec --soft-fail .
```

### Flags
- `-f <format>` - Output format (default, json, csv, checkstyle, junit, sarif, gif)
- `-s <severity>` - Minimum severity (CRITICAL, HIGH, MEDIUM, LOW)
- `-e <check>` - Exclude specific checks
- `-m` - Soft fail mode

### Common Issues Detected
- Unencrypted resources
- Public access misconfiguration
- Missing logging
- Weak security groups
- Unencrypted data transfer
- Missing backup configuration

---

## 🎯 Recommended Configuration

### Minimal Security Setup
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: gitleaks_detect        # Critical: Prevent secret leaks
      - id: yamllint_lint          # Prevent YAML errors
        args: ['-s']               # Strict mode
```

### Standard DevOps Setup
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: gitleaks_detect
      - id: shellcheck_check
        args: ['-s', 'warning']
      - id: yamllint_lint
      - id: hadolint_lint
```

### Comprehensive DevSecOps Setup
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      # Secret scanning (critical)
      - id: gitleaks_detect
        args: ['-v']
      
      # Code quality
      - id: shellcheck_check
        args: ['-s', 'warning', '-f', 'gcc']
      - id: yamllint_lint
        args: ['-s']
      - id: hadolint_lint
        args: ['-f', 'json']
      
      # Infrastructure security
      - id: tfsec_scan
        args: ['-s', 'HIGH', '-f', 'json']
        files: \.tf$
```

---

## 📊 Tool Comparison

| Tool | Speed | Accuracy | False Positives | Learning Curve |
|------|-------|----------|-----------------|----------------|
| **Gitleaks** | ⚡⚡⚡ | ⭐⭐⭐⭐ | Low | Easy |
| **Hadolint** | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | Very Low | Easy |
| **ShellCheck** | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | Low | Easy |
| **yamllint** | ⚡⚡⚡ | ⭐⭐⭐⭐ | Medium | Easy |
| **tfsec** | ⚡⚡ | ⭐⭐⭐⭐ | Low | Medium |

---

## 🚀 Quick Start

### 1. Install All Tools
```bash
# macOS
brew install gitleaks hadolint shellcheck yamllint tfsec

# Linux (Ubuntu/Debian)
# See individual tool documentation for Linux installation
```

### 2. Create .pre-commit-config.yaml
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: gitleaks_detect
      - id: hadolint_lint
      - id: shellcheck_check
      - id: yamllint_lint
      - id: tfsec_scan
```

### 3. Install and Run
```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

---

## 💡 Best Practices

### 1. Start with Critical Tools First
Begin with `gitleaks` - it's the most critical for security.

### 2. Use Appropriate Severity Levels
```yaml
# Development
- id: shellcheck_check
  args: ['-s', 'info']  # Show everything

# CI/CD
- id: shellcheck_check
  args: ['-s', 'error']  # Only block on errors
```

### 3. Configure for Your Workflow
Create tool-specific config files:
- `.gitleaks.toml`
- `.hadolint.yaml`
- `.yamllint`
- `.tfsec/config.yml`

### 4. Handle False Positives
```yaml
# Exclude specific checks
- id: shellcheck_check
  args: ['-x', 'SC2086,SC2034']

- id: tfsec_scan
  args: ['-e', 'aws-s3-enable-versioning']
```

### 5. Use in CI/CD
```yaml
# GitHub Actions
- name: Run pre-commit
  uses: pre-commit/action@v3.0.0
  with:
    extra_args: --all-files
```

---

## 🐛 Troubleshooting

### Gitleaks False Positives
```toml
# .gitleaks.toml
[allowlist]
paths = [
  '''tests/fixtures/.*''',
]
```

### ShellCheck Ignoring Sourced Files
```bash
# Add to script
# shellcheck source=./lib/common.sh
source ./lib/common.sh
```

### yamllint Too Strict
```yaml
# .yamllint
extends: relaxed
rules:
  line-length: disable
```

### tfsec Excluding Checks
```bash
# Inline in Terraform
#tfsec:ignore:aws-s3-enable-bucket-encryption
resource "aws_s3_bucket" "example" {
  # ...
}
```

---

## 📚 Additional Resources

- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [Hadolint Documentation](https://github.com/hadolint/hadolint)
- [ShellCheck Wiki](https://www.shellcheck.net/)
- [yamllint Documentation](https://yamllint.readthedocs.io/)
- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)

---

## 🎓 Next Steps

1. **Test locally**: Run `cd tests && ./run_all_tests.sh`
2. **Integrate gradually**: Start with one tool, then add more
3. **Customize configs**: Create tool-specific configuration files
4. **Monitor results**: Track findings and adjust severity levels
5. **Educate team**: Share documentation and best practices
