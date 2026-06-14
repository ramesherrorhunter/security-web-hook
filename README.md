# security-web-hook

Pre-commit Git hook that blocks commits containing secrets, PII, vulnerabilities, insecure IaC, and Docker misconfigurations using **5 security tools**.

## Tools

| # | Tool | Purpose |
|---|------|---------|
| 1 | **Gitleaks** | Secret & PII scanning (API keys, tokens, passwords, emails, phone numbers, .env files) |
| 2 | **Checkov** | IaC misconfiguration scanning (Terraform, YAML, Dockerfile) |
| 3 | **Semgrep** | Static analysis / SAST (code vulnerabilities) |
| 4 | **Trivy** | Vulnerability scanning (dependencies, containers) |
| 5 | **Dockle** | Docker image best practices & CIS benchmarks |

## Prerequisites

```bash
# Gitleaks - secret scanning
brew install gitleaks

# Checkov - IaC security
pip install checkov

# Semgrep - static analysis
pip install semgrep

# Trivy - vulnerability scanning
brew install trivy

# Dockle - Docker best practices
brew install goodwithtech/r/dockle
```

## Setup

```bash
./install.sh
```

## Project Structure

```
security-web-hook/
├── hooks/pre-commit   # Pre-commit hook (5 security checks)
├── install.sh         # One-command installer
├── .gitleaks.toml     # Custom Gitleaks rules (secrets + PII detection)
├── .gitignore         # Prevents .env from being tracked
└── README.md
```

## How It Works

On every `git commit`, the hook runs these checks on **staged files only**:

1. **Gitleaks** → scans for secrets & PII (API keys, tokens, passwords, emails, phone numbers, .env files)
2. **Checkov** → scans IaC files (`.tf`, `.yml`, `.yaml`, `.json`, `Dockerfile`)
3. **Semgrep** → static analysis on code (`.py`, `.js`, `.ts`, `.java`, `.go`, `.rb`, `.php`, `.c`, `.cpp`)
4. **Trivy** → scans dependency files (`package-lock.json`, `requirements.txt`, `go.sum`, `pom.xml`, etc.)
5. **Dockle** → checks Docker image against CIS benchmarks (requires a built image)

If **any** check fails → commit is **blocked**.  
If a tool is not installed → shows ⚠️ warning and skips (other checks still run).

## Detailed Findings Report

When issues are found, the hook shows **severity, file, line number, and rule**:

```
🔒 Running security checks before commit...

🔍 [1/5] Running Gitleaks (secret scanning)...
❌ Gitleaks found secrets:
┌──────────────────────────────────────────────────────────
│ Finding #1
│   Rule:     email-address
│   File:     name.txt
│   Line:     1
│   Secret:   ramesh.lodh@gmail.com
│   Severity: HIGH
│
│ Finding #2
│   Rule:     phone-number
│   File:     name.txt
│   Line:     3
│   Secret:   mob: 123456789
│   Severity: HIGH
│
└──────────────────────────────────────────────────────────

🚫 Security checks FAILED. Commit blocked. Fix the issues above.
```

### Other tool finding formats:

```
❌ Checkov found issues:
┌──────────────────────────────────────────────────────────
│ [HIGH] CKV_AWS_18: Ensure S3 bucket has access logging enabled
│   File: /main.tf
│   Resource: aws_s3_bucket.example
└──────────────────────────────────────────────────────────

❌ Semgrep found issues:
┌──────────────────────────────────────────────────────────
│ [ERROR] python.flask.security.injection.sql-injection
│   File: app.py:15
│   Message: Possible SQL injection via string concatenation
└──────────────────────────────────────────────────────────

❌ Trivy found vulnerabilities:
┌──────────────────────────────────────────────────────────
│ [CRITICAL] CVE-2023-1234: express
│   File: package-lock.json
│   Title: Prototype pollution in Express
└──────────────────────────────────────────────────────────

❌ Dockle found issues:
┌──────────────────────────────────────────────────────────
│ [FATAL] CIS-DI-0001: Create a user for the container
│   → No USER instruction in Dockerfile
└──────────────────────────────────────────────────────────
```

## Custom Rules (`.gitleaks.toml`)

In addition to Gitleaks default rules (AWS keys, GitHub tokens, private keys, etc.), custom rules detect:

| Rule | Catches |
|------|---------|
| `generic-password` | Any `password:`, `secret:`, `token:` assignments |
| `env-file` | Any content in `.env` files |
| `email-address` | Email addresses in any file |
| `phone-number` | Phone/mobile numbers in any file |

## Successful Commit

```
🔒 Running security checks before commit...

🔍 [1/5] Running Gitleaks (secret scanning)...
✅ Gitleaks: No secrets detected.

🔍 [2/5] Running Checkov (IaC security scanning)...
✅ Checkov: No IaC files staged, skipping.

🔍 [3/5] Running Semgrep (static analysis)...
✅ Semgrep: No code files staged, skipping.

🔍 [4/5] Running Trivy (vulnerability scanning)...
✅ Trivy: No dependency/container files staged, skipping.

🔍 [5/5] Running Dockle (Docker best practices)...
✅ Dockle: No Dockerfiles staged, skipping.

🎉 All security checks passed. Proceeding with commit.
```

## Bypass (emergency only)

```bash
git commit --no-verify -m "your message"
```

## Removing a Previously Committed Secret

```bash
git rm --cached .env
git commit -m "remove .env from tracking"
```

The `.gitignore` will prevent it from being re-added accidentally.