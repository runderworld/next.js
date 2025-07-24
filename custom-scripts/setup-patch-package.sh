#!/usr/bin/env bash
set -euo pipefail

# 1. Install dev dependencies
echo "Installing patch-package helpers…"
npm install --save-dev patch-package postinstall-postinstall

# 2. Run postinstall to apply patches (after npm i, before patch-package setup)
echo "Running npm install to update node_modules…"
npm install

# 3. Find and regenerate next+*.patch
echo "Updating next+*.patch file…"
NEXT_PATCH=$(find patches/ -name 'next+*.patch' | head -n 1)

if [[ -z "$NEXT_PATCH" ]]; then
  echo "❌ No next+*.patch found in patches/. Please create one before running setup."
  exit 1
fi

# Regenerate patch for Next.js after install (customize as needed)
# Example assumes source is patched already and this just regenerates patch file
echo "Recreating patch for: $NEXT_PATCH"
npx patch-package next --patch-dir patches

# 4. Ensure postinstall runs patch-package
echo "Setting up postinstall script…"
if npm pkg get scripts.postinstall &>/dev/null; then
  npm pkg set scripts.postinstall="patch-package"
else
  sed -i.bak -E 's#"postinstall": *"[^"]*"#"postinstall": "patch-package"#' package.json || \
  sed -i.bak '/"scripts": {/a \ \ \ \ "postinstall": "patch-package",' package.json
  rm package.json.bak
fi

# 5. Stage & commit updated files
echo "Staging and committing patch and package files…"
git add "$NEXT_PATCH" package.json package-lock.json
git commit -m "chore: setup patch-package and regenerate $NEXT_PATCH"

echo "✅ Patch-package is wired up and patch file refreshed."

