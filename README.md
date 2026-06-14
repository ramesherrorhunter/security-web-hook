# 🔒 Security Web Hook

> A pre-commit Git hook that **automatically scans your code before every commit** and blocks secrets, vulnerabilities, and misconfigurations from reaching your repository.

---

## ⚡ Quick Start (3 steps)

```bash
# 1. Clone the repo
git clone https://github.com/ramesherrorhunter/security-web-hook.git

# 2. Go into the project
cd security-web-hook

# 3. Install the hook
./install.sh
```

That's it! The hook is now active. Every `git commit` will be scanned automatically.

---

## 🛡️ What It Catches

| Tool | What it detects | Example |
|------|----------------|---------|
| **Gitleaks** | Secrets & PII | API keys, passwords, emails, phone numbers, `.env` files |
| **Checkov** | IaC misconfigs | Insecure S3 buckets, open security groups, missing encryption |
| **Semgrep** | Code vulnerabilities | SQL injection, XSS, hardcoded secrets in code |
| **Trivy** | Dependency CVEs | Known vulnerabilities in packages |
| **Dockle** | Docker issues | Missing USER instruction, running as root |

---

## 📋 Prerequisites

Install the security tools (macOS):

```bash
brew install gitleaks          # Secret scanning
brew install trivy             # Vulnerability scanning
brew install goodwithtech/r/dockle  # Docker scanning
pip install checkov            # IaC security
pip install semgrep            # Static analysis
```

> 💡 Don't worry — if a tool is not installed, the hook **skips it** with a warning. Other checks still run.

---

## 📁 Project Structure

```
security-web-hook/
├── hooks/pre-commit   ← The hook script (runs 5 security checks)
├── install.sh         ← One-command installer
├── .gitleaks.toml     ← Custom rules (PII + secret patterns)
├── .gitignore         ← Blocks .env from being committed
├── LICENSE            ← MIT License
└── README.md          ← You are here
```

---

## 🔄 How It Works

```
git commit -m "my changes"
        │
        ▼
┌─────────────────────────────┐
│   PRE-COMMIT HOOK RUNS      │
│                             │
│  1. Gitleaks  → secrets?    │
│  2. Checkov   → IaC safe?   │
│  3. Semgrep   → code safe?  │
│  4. Trivy     → deps safe?  │
│  5. Dockle    → docker ok?  │
│                             │
└──────────┬──────────────────┘
           │
     ┌─────┴─────┐
     │           │
  ALL PASS    ANY FAIL
     │           │
     ▼           ▼
  ✅ Commit    🚫 Blocked
  goes through   (fix issues first)
```

---

## 📊 Detailed Findings Report

When the hook finds issues, it shows **exactly what and where**:

### Secrets / PII detected:
```
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
└──────────────────────────────────────────────────────────
```

### IaC misconfigurations:
```
❌ Checkov found issues:
┌──────────────────────────────────────────────────────────
│ [HIGH] CKV_AWS_18: Ensure S3 bucket has access logging enabled
│   File: /main.tf
│   Resource: aws_s3_bucket.example
└──────────────────────────────────────────────────────────
```

### Code vulnerabilities:
```
❌ Semgrep found issues:
┌──────────────────────────────────────────────────────────
│ [ERROR] python.flask.security.injection.sql-injection
│   File: app.py:15
│   Message: Possible SQL injection via string concatenation
└──────────────────────────────────────────────────────────
```

### Dependency vulnerabilities:
```
❌ Trivy found vulnerabilities:
┌──────────────────────────────────────────────────────────
│ [CRITICAL] CVE-2023-1234: express
│   File: package-lock.json
│   Title: Prototype pollution in Express
└──────────────────────────────────────────────────────────
```

### Docker issues:
```
❌ Dockle found issues:
┌──────────────────────────────────────────────────────────
│ [FATAL] CIS-DI-0001: Create a user for the container
│   → No USER instruction in Dockerfile
└──────────────────────────────────────────────────────────
```

---

## ✅ Clean Commit (all checks pass)

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

---

## 🛠️ Custom Rules (`.gitleaks.toml`)

Beyond default secret patterns, the hook detects:

| Rule | What it catches |
|------|----------------|
| `generic-password` | `password:`, `secret:`, `token:` assignments |
| `env-file` | Any content in `.env` files |
| `email-address` | Email addresses in any file |
| `phone-number` | Phone/mobile numbers in any file |

---

## 🚀 Use in Your Own Project

Want to add this hook to **any** existing project? Just run these commands inside your project:

```bash
# 1. Go into your project (must be a git repo)
cd your-project-folder

# 2. Create hooks directory (if it doesn't exist)
mkdir -p .git/hooks

# 3. Download the hook
curl -o .git/hooks/pre-commit https://raw.githubusercontent.com/ramesherrorhunter/security-web-hook/main/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 4. Download custom Gitleaks rules
curl -o .gitleaks.toml https://raw.githubusercontent.com/ramesherrorhunter/security-web-hook/main/.gitleaks.toml
```

That's it! Your project now has security scanning on every commit.

> ⚠️ **Important:** You must run these commands **inside a git repository**. If your project isn't a git repo yet, run `git init` first.

### Or clone and copy manually:

```bash
git clone https://github.com/ramesherrorhunter/security-web-hook.git /tmp/sec-hook
cp /tmp/sec-hook/hooks/pre-commit YOUR_PROJECT/.git/hooks/pre-commit
cp /tmp/sec-hook/.gitleaks.toml YOUR_PROJECT/.gitleaks.toml
chmod +x YOUR_PROJECT/.git/hooks/pre-commit
```

> 💡 Each developer on the team needs to run this once. The `.git/hooks/` folder is not pushed to the repo.

---

## ⚠️ Bypass (emergency only)

```bash
git commit --no-verify -m "your message"
```

> ⚠️ Use this only when you're sure the flagged content is safe (e.g., test fixtures, documentation examples).

---

## 🧹 Fix: Remove a Previously Committed Secret

If a secret was committed before the hook was installed:

```bash
# Remove from git tracking (file stays on disk)
git rm --cached .env
git commit -m "remove .env from tracking"
```

The `.gitignore` prevents it from being re-added.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
