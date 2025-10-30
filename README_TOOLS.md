# DevSecOps Pre-Commit Hooks - Tool Reference

Quick reference guide for all available hooks and their usage.

## 📦 Installation Commands

```bash
# Kubernetes Analysis Tools
brew install FairwindsOps/tap/pluto
brew install FairwindsOps/tap/nova
brew install derailed/popeye/popeye
brew install kube-score/tap/kube-score

# Security Scanning Tools
brew install snyk/tap/snyk && snyk auth
brew install aquasecurity/trivy/trivy
brew install checkov  # or: pip install checkov

# Required Dependencies
brew install kubectl
brew install helm
```

## 🔍 Available Hooks

### Kubernetes API & Best Practices

#### `pluto_detect_files`
Detect deprecated Kubernetes API versions in manifest files.
```yaml
- id: pluto_detect_files
  args: ['-d', '.', '-o', 'wide']
```

#### `pluto_detect_helm`
Detect deprecated APIs in Helm releases (requires cluster).
```yaml
- id: pluto_detect_helm
  args: ['-k', 'my-context', '-n', 'default']
```

#### `pluto_detect_api`
Detect deprecated APIs in active cluster resources.
```yaml
- id: pluto_detect_api
  args: ['-r', '-o', 'json']
```

#### `kubescore_score`
Score Kubernetes manifests for best practices.
```yaml
- id: kubescore_score
  args: ['-v', '-o', 'json']
```

### Helm Management

#### `nova_search_updates`
Find outdated Helm chart releases (requires cluster).
```yaml
- id: nova_search_updates
  args: ['-k', 'my-context', '-w']
```

### Cluster Health

#### `popeye_scan`
Scan Kubernetes cluster for resource issues (requires cluster).
```yaml
- id: popeye_scan
  args: ['-k', 'my-context', '-s', '80']
```

### Security Scanning

#### `snyk_test`
Test project dependencies for vulnerabilities.
```yaml
- id: snyk_test
  args: ['-s', 'high', '-j']
```

#### `snyk_container`
Scan container images for vulnerabilities.
```yaml
- id: snyk_container
  args: ['-s', 'critical']
```

#### `snyk_iac`
Scan Infrastructure as Code for security issues.
```yaml
- id: snyk_iac
  args: ['-s', 'high', '-j']
```

#### `trivy_fs`
Scan filesystem for vulnerabilities and misconfigurations.
```yaml
- id: trivy_fs
  args: ['-s', 'CRITICAL,HIGH', '-f', 'json']
```

#### `trivy_image`
Scan container images for vulnerabilities.
```yaml
- id: trivy_image
  args: ['-s', 'CRITICAL', '-e', '1']
```

#### `checkov_scan`
Scan IaC files for security and compliance issues.
```yaml
- id: checkov_scan
  args: ['-f', 'kubernetes', '-c', '-s']
```

## 🎯 Common Use Cases

### Minimal Security Setup
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: kubescore_score
      - id: trivy_fs
        args: ['-s', 'CRITICAL,HIGH']
```

### Comprehensive DevSecOps Pipeline
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      # Best practices
      - id: kubescore_score
        args: ['-v']
      
      # Deprecated APIs
      - id: pluto_detect_files
        args: ['-d', '.', '-o', 'wide']
      
      # Security scanning
      - id: snyk_iac
        args: ['-s', 'high']
      
      - id: trivy_fs
        args: ['-s', 'CRITICAL,HIGH']
      
      - id: checkov_scan
        args: ['-f', 'kubernetes', '-c']
```

### CI/CD Optimized
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      # Fast checks
      - id: kubescore_score
        args: ['-o', 'json']
      
      - id: pluto_detect_files
        args: ['-o', 'json']
      
      # Security (fail on critical only)
      - id: trivy_fs
        args: ['-s', 'CRITICAL', '-e', '1', '-f', 'json']
      
      - id: checkov_scan
        args: ['-f', 'kubernetes', '-c', '-q']
```

## 🔧 Flag Reference

### Common Flags

| Flag | Tools | Description |
|------|-------|-------------|
| `-o <format>` | pluto, kubescore | Output format (json, wide, etc.) |
| `-s <severity>` | snyk, trivy | Severity threshold |
| `-f <format>` | trivy, checkov | Output format |
| `-v` | kubescore | Verbose output |
| `-k <context>` | pluto, nova, popeye | Kubernetes context |
| `-n <namespace>` | pluto, nova | Kubernetes namespace |
| `-j` | snyk | JSON output |
| `-c` | checkov | Compact output |
| `-q` | checkov | Quiet mode |

### Severity Levels

**Snyk:** `low`, `medium`, `high`, `critical`

**Trivy:** `UNKNOWN`, `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`

**Checkov:** Uses built-in severity (can use `-s` for soft-fail)

## 🧪 Testing Your Setup

```bash
# Test all hooks
cd tests && ./run_all_tests.sh

# Test specific tool
./test_kubescore.sh
./test_snyk.sh
./test_trivy.sh
./test_checkov.sh

# Test with your files
pre-commit run --all-files
pre-commit run --files path/to/file.yaml
```

## 📊 Tool Comparison Matrix

| Feature | Kube-score | Snyk | Trivy | Checkov | Pluto |
|---------|------------|------|-------|---------|-------|
| **K8s Best Practices** | ✅ | ❌ | ⚠️ | ⚠️ | ❌ |
| **Vulnerability Scanning** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **IaC Security** | ❌ | ✅ | ✅ | ✅ | ❌ |
| **Deprecated APIs** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Container Scanning** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Requires Auth** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Requires Cluster** | ❌ | ❌ | ❌ | ❌ | Optional |
| **Speed** | Fast | Medium | Fast | Medium | Fast |
| **Free Tier** | ✅ | Limited | ✅ | ✅ | ✅ |

## 💡 Best Practices

1. **Layer Your Security**
   - Use multiple tools for comprehensive coverage
   - Kube-score for best practices
   - Trivy for vulnerabilities
   - Checkov for compliance

2. **Set Appropriate Thresholds**
   - Start with `high` or `critical` severity
   - Gradually lower threshold as you fix issues
   - Use soft-fail mode during migration

3. **Optimize for CI/CD**
   - Use JSON output for parsing
   - Set exit codes appropriately
   - Cache tool databases when possible

4. **Regular Updates**
   - Keep tools updated: `brew upgrade`
   - Update vulnerability databases
   - Review new security checks

## 🐛 Troubleshooting

### Hook fails with "command not found"
```bash
# Verify installation
which <tool-name>

# Check PATH
echo $PATH

# Reinstall if needed
brew reinstall <tool-name>
```

### Snyk authentication issues
```bash
# Check authentication
snyk auth check

# Re-authenticate
snyk auth

# Verify API token
echo $SNYK_TOKEN
```

### Too many false positives
```bash
# Increase severity threshold
args: ['-s', 'high']  # or 'critical'

# Use soft-fail mode
args: ['-s']  # checkov

# Exclude specific checks
args: ['--skip-check', 'CKV_K8S_1']  # checkov
```

### Performance issues
```bash
# Limit file types
files: (deployment|service)\.yaml$

# Use specific directories
args: ['-d', 'k8s/']

# Run in parallel (if possible)
require_serial: false
```

## 📚 Additional Resources

- [Pre-commit Documentation](https://pre-commit.com/)
- [Tool-specific docs](./DEVSECOPS_HOOKS.md)
- [Test examples](./tests/)
- [GitHub Actions integration](https://pre-commit.com/#github-actions-example)
