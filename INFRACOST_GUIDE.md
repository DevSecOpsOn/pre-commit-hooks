# Infracost Hook - Cloud Cost Estimation Guide

Automatically estimate cloud infrastructure costs before opening pull requests.

## 🎯 Overview

Infracost shows cloud cost estimates for Terraform changes **before** you commit, helping you:
- 💰 Understand cost implications of infrastructure changes
- 📊 Compare costs between different configurations
- 🚨 Catch expensive mistakes early
- 📈 Track cost trends over time

---

## 📦 Installation

### 1. Install Infracost
```bash
# macOS
brew install infracost/infracost/infracost

# Linux
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Windows (PowerShell)
choco install infracost
```

### 2. Authenticate
```bash
# Register and get API key (free for individuals)
infracost auth login

# Or set API key directly
infracost configure set api_key YOUR_API_KEY
```

### 3. Verify Installation
```bash
infracost --version
infracost configure get api_key
```

---

## 🚀 Available Hooks

### 1. infracost_breakdown
Shows complete cost breakdown for your infrastructure.

```yaml
- id: infracost_breakdown
  args: ['-p', 'terraform/']
```

**Use when**: You want to see total infrastructure costs

### 2. infracost_diff
Shows cost difference compared to a baseline.

```yaml
- id: infracost_diff
  args: ['-p', 'terraform/', '-c', 'infracost-base.json']
```

**Use when**: You want to see how costs changed (perfect for PRs)

---

## 🎨 Usage Examples

### Basic Cost Breakdown
```yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: infracost_breakdown
        files: \.tf$
```

### With Specific Directory
```yaml
- id: infracost_breakdown
  args: ['-p', 'terraform/production']
  files: ^terraform/production/.*\.tf$
```

### With JSON Output (for CI/CD)
```yaml
- id: infracost_breakdown
  args: ['-p', '.', '-f', 'json']
```

### With Terraform Variables
```yaml
- id: infracost_breakdown
  args: ['-p', '.', '-t', 'terraform.tfvars']
```

### Cost Diff for Pull Requests
```yaml
- id: infracost_diff
  args: ['-p', '.', '-c', 'infracost-base.json', '-f', 'table']
```

---

## 🔧 Available Flags

### Common Flags

| Flag | Description | Example |
|------|-------------|---------|
| `-p <path>` | Path to Terraform directory | `-p terraform/` |
| `-f <format>` | Output format | `-f json` |
| `-t <file>` | Terraform var file | `-t prod.tfvars` |
| `-s` | Show skipped resources | `-s` |
| `-c <file>` | Compare to baseline (diff only) | `-c base.json` |

### Output Formats

- `table` - Human-readable table (default)
- `json` - JSON output for parsing
- `html` - HTML report
- `diff` - Git-style diff
- `github-comment` - Formatted for GitHub PR comments
- `gitlab-comment` - Formatted for GitLab MR comments
- `azure-repos-comment` - Formatted for Azure Repos PR comments
- `slack-message` - Formatted for Slack

---

## 💡 Real-World Scenarios

### Scenario 1: Pre-Commit Cost Check
```yaml
# Show costs before every commit
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: infracost_breakdown
        args: ['-p', 'terraform/', '-f', 'table']
        files: \.tf$
```

### Scenario 2: Pull Request Cost Diff
```yaml
# Show cost changes in PRs
- id: infracost_diff
  args: ['-p', 'terraform/', '-f', 'github-comment']
  stages: [manual]  # Run manually in CI
```

### Scenario 3: Multi-Environment
```yaml
# Different configs for different environments
- id: infracost_breakdown
  name: Infracost - Production
  args: ['-p', 'terraform/prod', '-t', 'prod.tfvars']
  files: ^terraform/prod/.*\.tf$

- id: infracost_breakdown
  name: Infracost - Staging
  args: ['-p', 'terraform/staging', '-t', 'staging.tfvars']
  files: ^terraform/staging/.*\.tf$
```

### Scenario 4: Cost Threshold Enforcement
```bash
# In CI/CD, fail if cost increase > $100/month
infracost diff --path . --compare-to base.json --format json \
  | jq -e '.diffTotalMonthlyCost < 100'
```

---

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
name: Infracost
on: [pull_request]

jobs:
  infracost:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Infracost
        uses: infracost/actions/setup@v2
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}
      
      - name: Generate baseline
        run: |
          git checkout main
          infracost breakdown --path . --format json --out infracost-base.json
      
      - name: Generate diff
        run: |
          git checkout ${{ github.head_ref }}
          infracost diff --path . --compare-to infracost-base.json \
            --format github-comment --out infracost-comment.md
      
      - name: Post comment
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const comment = fs.readFileSync('infracost-comment.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

### GitLab CI
```yaml
infracost:
  image: infracost/infracost:ci-latest
  stage: test
  before_script:
    - infracost configure set api_key $INFRACOST_API_KEY
  script:
    - git checkout $CI_MERGE_REQUEST_TARGET_BRANCH_NAME
    - infracost breakdown --path . --format json --out infracost-base.json
    - git checkout $CI_COMMIT_REF_NAME
    - infracost diff --path . --compare-to infracost-base.json --format gitlab-comment
  only:
    - merge_requests
```

---

## 📊 Understanding Output

### Cost Breakdown Example
```
Project: terraform/

 Name                                     Monthly Qty  Unit   Monthly Cost

 aws_instance.web_server
 ├─ Instance usage (Linux/UNIX, on-demand, t3.small)  730  hours        $15.18
 └─ root_block_device
    └─ Storage (general purpose SSD, gp3)              30  GB            $2.40

 aws_db_instance.database
 ├─ Database instance (on-demand, db.t3.small)        730  hours        $29.93
 └─ Storage (general purpose SSD, gp3)                 50  GB            $5.75

 aws_nat_gateway.main
 ├─ NAT gateway                                       730  hours        $32.85
 └─ Data processed                          Monthly cost depends on usage: $0.045 per GB

 OVERALL TOTAL                                                          $86.11
```

### Cost Diff Example
```
Project: terraform/

~ aws_instance.web_server
  +$7.59 ($15.18 → $22.77)
  ~ Instance usage (Linux/UNIX, on-demand, t3.small → t3.medium)
    +$7.59 ($15.18 → $22.77)

+ aws_nat_gateway.main
  +$32.85
  + NAT gateway
    +$32.85

Monthly cost change for terraform/
Amount:  +$40.44 ($86.11 → $126.55)
Percent: +47%
```

---

## 🎯 Best Practices

### 1. Use in Development
```yaml
# Run on every commit during development
- id: infracost_breakdown
  args: ['-p', '.']
```

### 2. Generate Baselines
```bash
# Generate baseline from main branch
git checkout main
infracost breakdown --path . --format json --out infracost-base.json
git checkout feature-branch
```

### 3. Set Cost Budgets
```bash
# Alert if monthly cost > $1000
COST=$(infracost breakdown --path . --format json | jq '.totalMonthlyCost')
if (( $(echo "$COST > 1000" | bc -l) )); then
  echo "⚠️  Cost exceeds budget: \$$COST/month"
  exit 1
fi
```

### 4. Track Cost Trends
```bash
# Save cost reports over time
infracost breakdown --path . --format json \
  --out "costs/$(date +%Y-%m-%d).json"
```

### 5. Use with Terraform Workspaces
```bash
# Different costs for different workspaces
terraform workspace select production
infracost breakdown --path . --terraform-workspace production
```

---

## 🔍 What Infracost Analyzes

### Supported Resources (500+)
- **Compute**: EC2, ECS, EKS, Lambda, Fargate
- **Storage**: S3, EBS, EFS, Glacier
- **Database**: RDS, DynamoDB, ElastiCache, Redshift
- **Networking**: VPC, NAT Gateway, Load Balancers, CloudFront
- **Containers**: ECR, ECS, EKS
- **Serverless**: Lambda, API Gateway, Step Functions
- **Analytics**: Athena, Glue, EMR, Kinesis
- **AI/ML**: SageMaker, Comprehend, Rekognition

### Cloud Providers
- ✅ AWS (500+ resources)
- ✅ Azure (300+ resources)
- ✅ Google Cloud (200+ resources)

---

## 🐛 Troubleshooting

### Issue: "API key not found"
```bash
# Solution: Authenticate
infracost auth login

# Or set manually
infracost configure set api_key YOUR_KEY
```

### Issue: "No Terraform files found"
```bash
# Solution: Specify correct path
infracost breakdown --path terraform/

# Or use current directory
infracost breakdown --path .
```

### Issue: "Terraform not initialized"
```bash
# Solution: Initialize Terraform first
terraform init
infracost breakdown --path .
```

### Issue: "Usage-based resources show $0"
```
# Some resources depend on usage (data transfer, requests, etc.)
# Infracost shows these as "Monthly cost depends on usage"
# You can set usage estimates in infracost-usage.yml
```

### Issue: "Slow performance"
```bash
# Solution: Use --sync-usage-file to cache
infracost breakdown --path . --sync-usage-file --usage-file infracost-usage.yml
```

---

## 📈 Advanced Features

### Usage-Based Costs
Create `infracost-usage.yml`:
```yaml
version: 0.1
resource_usage:
  aws_instance.web_server:
    operating_system: linux
    monthly_hrs: 730
  
  aws_nat_gateway.main:
    monthly_gb_data_processed: 1000  # 1TB/month
  
  aws_lambda_function.api:
    monthly_requests: 10000000  # 10M requests
    request_duration_ms: 500
```

Then use it:
```bash
infracost breakdown --path . --usage-file infracost-usage.yml
```

### Multi-Project Costs
```bash
# Combine costs from multiple projects
infracost breakdown --path project1/ --format json --out p1.json
infracost breakdown --path project2/ --format json --out p2.json
infracost output --path p1.json --path p2.json --format table
```

### Cost Policies
Create policies to enforce cost limits:
```yaml
# .infracost/policies.yml
policies:
  - name: "Cost increase limit"
    rules:
      - condition: percent_diff > 20
        action: fail
        message: "Cost increase exceeds 20%"
  
  - name: "Total cost limit"
    rules:
      - condition: total_monthly_cost > 10000
        action: warn
        message: "Total cost exceeds $10k/month"
```

---

## 💰 Pricing

### Infracost Cloud (Free Tier)
- ✅ Unlimited cost estimates
- ✅ Up to 10 team members
- ✅ Basic reporting
- ✅ Community support

### Infracost Cloud (Paid)
- ✅ Everything in free tier
- ✅ Unlimited team members
- ✅ Advanced reporting & dashboards
- ✅ Cost policies & guardrails
- ✅ Priority support
- ✅ SSO/SAML

### Self-Hosted (Open Source)
- ✅ Free forever
- ✅ No API key required
- ✅ Full control
- ✅ Limited to public pricing data

---

## 📚 Additional Resources

- [Infracost Documentation](https://www.infracost.io/docs/)
- [Supported Resources](https://www.infracost.io/docs/supported_resources/)
- [CI/CD Integrations](https://www.infracost.io/docs/integrations/cicd/)
- [Usage-Based Costs](https://www.infracost.io/docs/features/usage_based_resources/)
- [GitHub Repository](https://github.com/infracost/infracost)

---

## 🎉 Quick Start Summary

```bash
# 1. Install
brew install infracost/infracost/infracost

# 2. Authenticate
infracost auth login

# 3. Test
cd terraform/
infracost breakdown --path .

# 4. Add to pre-commit
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/DevSecOpsOn/pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: infracost_breakdown
        args: ['-p', 'terraform/']

# 5. Run
pre-commit run infracost_breakdown --all-files
```

---

**Infracost helps you understand the cost impact of infrastructure changes before they happen!** 💰📊
