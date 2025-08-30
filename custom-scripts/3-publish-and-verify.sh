#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
FINGERPRINT='runderworld.node.options.patch'
SEARCH_ROOT="packages/next/dist"
PACKAGE_FILE="packages/next/package.json"

# Parse optional --no-push flag
if [[ "${1:-}" == "--no-push" ]]; then
  DRY_RUN=true
  echo "🧪 Dry run mode enabled: will NOT publish to registry."
fi

# Rewrite package.json before publishing
echo "📝 Rewriting package.json for scoped publish..."
jq \
  --arg name "@runderworld/next-patched" \
  --arg version "$(jq -r .version "$PACKAGE_FILE")-patch" \
  '.name = $name | .version = $version | .publishConfig.access = "public" | .private = false' \
  "$PACKAGE_FILE" > "$PACKAGE_FILE.tmp" && mv "$PACKAGE_FILE.tmp" "$PACKAGE_FILE"

# Verify fingerprint
echo "🔍 Verifying patch fingerprint before publish..."
MATCH=$(grep -rn "$FINGERPRINT" "$SEARCH_ROOT" || true)

if [[ -n "$MATCH" ]]; then
  echo "✅ Patch verified: fingerprint found."
  echo "📄 Matched location(s):"
  echo "$MATCH"
else
  echo "❌ Patch verification failed: '$FINGERPRINT' not found in $SEARCH_ROOT"
  exit 1
fi

# Publish
if $DRY_RUN; then
  echo "✅ Dry run complete. Patch verified. Skipping publish."
else
  echo "📦 Publishing patched Next.js..."
  npm publish
  echo "✅ Published to npm registry."
fi

