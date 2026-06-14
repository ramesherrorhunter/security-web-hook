#!/bin/bash
set -e

HOOK_SRC="$(cd "$(dirname "$0")" && pwd)/hooks/pre-commit"
HOOK_DST="$(git rev-parse --show-toplevel)/.git/hooks/pre-commit"

echo "📦 Installing pre-commit hook..."
echo ""

# Check all prerequisites
echo "🔍 Checking prerequisites..."
MISSING=0

if command -v gitleaks &>/dev/null; then
    echo "  ✅ gitleaks"
else
    echo "  ❌ gitleaks       → brew install gitleaks"
    MISSING=1
fi

if command -v checkov &>/dev/null; then
    echo "  ✅ checkov"
else
    echo "  ❌ checkov        → pip install checkov"
    MISSING=1
fi

if command -v semgrep &>/dev/null; then
    echo "  ✅ semgrep"
else
    echo "  ❌ semgrep        → pip install semgrep"
    MISSING=1
fi

if command -v trivy &>/dev/null; then
    echo "  ✅ trivy"
else
    echo "  ❌ trivy          → brew install trivy"
    MISSING=1
fi

if command -v dockle &>/dev/null; then
    echo "  ✅ dockle"
else
    echo "  ❌ dockle         → brew install goodwithtech/r/dockle"
    MISSING=1
fi

echo ""
if [ $MISSING -ne 0 ]; then
    echo "⚠️  Some tools are missing. Install them for full security coverage."
    echo ""
fi

cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"
echo "✅ Hook installed at $HOOK_DST"
