#!/usr/bin/env bash
set -euo pipefail

FINGERPRINT='patchEdgeFunctionResponse'
SEARCH_ROOT="packages/next/dist"

echo "🔍 Searching for fingerprint '$FINGERPRINT' in $SEARCH_ROOT..."

MATCH=$(grep -rn "$FINGERPRINT" "$SEARCH_ROOT" || true)

if [[ -n "$MATCH" ]]; then
  echo "✅ Patch verified: fingerprint found."
  echo "📄 Matched location(s):"
  echo "$MATCH"
else
  echo "❌ Patch verification failed: '$FINGERPRINT' not found in $SEARCH_ROOT"
  exit 1
fi

