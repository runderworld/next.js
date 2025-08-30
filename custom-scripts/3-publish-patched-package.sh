#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false

# Parse optional --no-push flag
if [[ "${1:-}" == "--no-push" ]]; then
  DRY_RUN=true
  echo "🧪 Dry run mode enabled: will NOT publish to registry."
fi

echo "🔍 Running patch integrity check..."
bash custom-scripts/4-verify-patch-integrity.sh

if $DRY_RUN; then
  echo "✅ Dry run complete. Patch verified. Skipping publish."
else
  echo "📦 Publishing patched Next.js..."
  npm publish --access restricted
  echo "✅ Published to internal registry."
fi

