# DevSecOps Pre-Commit Hooks

Comprehensive collection of security and compliance hooks for Kubernetes and cloud-native applications.

## 🛡️ Security Scanning Tools

### Kube-score
Static code analysis for Kubernetes object definitions.

**Installation:**
```bash
brew install kube-score/tap/kube-score
```

**Hooks:**
- `kubescore-score` - Score Kubernetes manifests for best practices

**Usage:**
```yaml
- repo: https://github.com/DevSecOpsOn/pre-commit-hooks
  rev: v1.0.0
  hooks:
    - id: kubescore-score
      args: ['-v']  # verbose output
```

**Available flags:**
- `-o <format>` - Output format (json, ci, human)
- `-e` - Enable optional tests
- `-v` - Verbose output

---

### Snyk
Find and fix vulnerabilities in dependencies, containers, and IaC.

**Installation:**
```bash
brew install snyk/tap/snyk
snyk auth  # Authenticate with your account
```

**Hooks:**
- `snyk-test` - Test dependencies for vulnerabilities
- `snyk-container` - Scan container images
- `snyk-iac` - Scan Infrastructure as Code files

**Usage:**
```yaml
- repo: https://github.com/DevSecOpsOn/pre-commit-hooks
  rev: v1.0.0
  hooks:
    - id: snyk-iac
      args: ['-s', 'high']  # Only fail on high severity
    - id: snyk-container
      args: ['-s', 'critical']
```

**Available flags:**
- `-s <severity>` - Severity threshold (low, medium, high, critical)
- `-j` - JSON output
- `-d` - Scan all projects (snyk-test)
- `-f <file>` - Dockerfile path (snyk-container)
- `-r` - Generate report (snyk-iac)

---

### Trivy
Comprehensive vulnerability scanner for containers and filesystems.

**Installation:**
```bash
brew install aquasecurity/trivy/trivy
```

**Hooks:**
- `trivy-fs` - Scan filesystem for vulnerabilities
- `trivy-image` - Scan container images

**Usage:**
```yaml
- repo: https://github.com/DevSecOpsOn/pre-commit-hooks
  rev: v1.0.0
  hooks:
    - id: trivy-fs
      args: ['-s', 'CRITICAL,HIGH']
    - id: trivy-image
      args: ['-s', 'CRITICAL', '-e', '1']
```

**Available flags:**
- `-s <severities>` - Severity filter (UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL)
- `-f <format>` - Output format (table, json, sarif)
- `-e <code>` - Exit code on vulnerabilities found

---

### Checkov
Static code analysis for Infrastructure as Code.

**Installation:**
```bash
brew install checkov
# or
pip install checkov
```

**Hooks:**
- `checkov-scan` - Scan IaC files for security issues

**Usage:**
```yaml
- repo: https://github.com/DevSecOpsOn/pre-commit-hooks
  rev: v1.0.0
  hooks:
    - id: checkov-scan
      args: ['-f', 'kubernetes', '-c']
```

**Available flags:**
- `-d <directory>` - Directory to scan
- `-f <framework>` - Framework (kubernetes, terraform, cloudformation, etc.)
- `-s` - Soft-fail mode (always exit 0)
- `-q` - Quiet mode
- `-c` - Compact output

---

## 📊 Kubernetes Analysis Tools

### Pluto
Detect deprecated Kubernetes API versions.

**Hooks:**
- `pluto-detect-files` - Scan files for deprecated APIs
- `pluto-detect-helm` - Scan Helm releases
- `pluto-detect-api` - Scan cluster API resources

### Nova
Find outdated Helm charts.

**Hooks:**
- `nova-search-updates` - Find outdated Helm releases

### Popeye
Kubernetes cluster sanitizer.

**Hooks:**
- `popeye-scan` - Scan cluster for issues

---

## 🚀 Quick Start

### 1. Install Tools

```bash
# Core Kubernetes tools
brew install kubectl helm

# Analysis tools
brew install FairwindsOps/tap/pluto
brew install FairwindsOps/tap/nova
brew install derailed/popeye/popeye
brew install kube-score/tap/kube-score

# Security tools
brew install snyk/tap/snyk
brew install aquasecurity/trivy/trivy
brew install checkov

# Authenticate Snyk
snyk auth
```

### 2. Create `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      # Kubernetes best practices
      - id: kubescore-score
        args: ['-v']
      
      # Deprecated API detection
      - id: pluto-detect-files
        args: ['-d', '.', '-o', 'wide']
      
      # Security scanning
      - id: snyk-iac
        args: ['-s', 'high']
      
      - id: trivy-fs
        args: ['-s', 'CRITICAL,HIGH']
      
      - id: checkov-scan
        args: ['-f', 'kubernetes', '-c']
```

### 3. Install and Run

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files

# Or run on specific files
pre-commit run --files path/to/deployment.yaml
```

---

## 🧪 Testing

Run the test suite to validate all hooks:

```bash
cd tests
./run_all_tests.sh

# Or test individual tools
./test_kubescore.sh
./test_snyk.sh
./test_trivy.sh
./test_checkov.sh
```

---

## 📋 Hook Comparison

| Tool | Purpose | Requires Auth | Requires Cluster | Best For |
|------|---------|---------------|------------------|----------|
| **Kube-score** | K8s best practices | ❌ | ❌ | Manifest validation |
| **Snyk** | Vulnerability scanning | ✅ | ❌ | Multi-purpose security |
| **Trivy** | Vulnerability scanning | ❌ | ❌ | Container/FS scanning |
| **Checkov** | IaC security | ❌ | ❌ | Policy compliance |
| **Pluto** | Deprecated APIs | ❌ | Optional | K8s upgrades |
| **Nova** | Helm updates | ❌ | ✅ | Helm management |
| **Popeye** | Cluster health | ❌ | ✅ | Cluster auditing |

---

## 🔧 Advanced Configuration

### Severity-Based Workflows

```yaml
# Fail on critical/high, warn on medium/low
- id: trivy-fs
  args: ['-s', 'CRITICAL,HIGH', '-e', '1']

- id: snyk-iac
  args: ['-s', 'high']

- id: checkov-scan
  args: ['-s']  # soft-fail mode
```

### Multi-Stage Scanning

```yaml
# Stage 1: Fast checks
- id: kubescore-score
- id: pluto-detect-files

# Stage 2: Security scans
- id: trivy-fs
- id: checkov-scan

# Stage 3: Deep analysis (optional)
- id: snyk-iac
  stages: [manual]
```

### Framework-Specific Scanning

```yaml
# Kubernetes
- id: checkov-scan
  args: ['-f', 'kubernetes']
  files: \.(yaml|yml)$

# Terraform
- id: checkov-scan
  args: ['-f', 'terraform']
  files: \.tf$

# Dockerfile
- id: checkov-scan
  args: ['-f', 'dockerfile']
  files: Dockerfile$
```

---

## 🐛 Troubleshooting

### Common Issues

**1. Tool not found**
```bash
# Check installation
which <tool-name>

# Reinstall if needed
brew reinstall <tool-name>
```

**2. Snyk authentication**
```bash
# Check auth status
snyk auth check

# Re-authenticate
snyk auth
```

**3. Permission errors**
```bash
# Make hooks executable
chmod +x hooks/**/*.sh
```

**4. Cluster connection issues**
```bash
# Verify kubectl context
kubectl config current-context

# Test connection
kubectl cluster-info
```

---

## 📚 Resources

- [Kube-score Documentation](https://kube-score.com/)
- [Snyk Documentation](https://docs.snyk.io/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Checkov Documentation](https://www.checkov.io/)
- [Pre-commit Framework](https://pre-commit.com/)

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Follow the existing hook structure
2. Add tests for new hooks
3. Update documentation
4. Ensure all tests pass

---

## 📄 License

MIT License - see LICENSE file for details
