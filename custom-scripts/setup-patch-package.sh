#!/usr/bin/env bash
set -euo pipefail

# 1. Install dev dependencies
echo "Installing patch-package helpers…"
npm install --save-dev patch-package postinstall-postinstall

# 2. Ensure a postinstall script
echo "Setting up postinstall script…"
# requires npm >=7.21.0; falls back to sed if npm pkg isn't available
if npm pkg get scripts.postinstall &>/dev/null; then
  npm pkg set scripts.postinstall="patch-package"
else
  # insert or replace the postinstall entry in package.json
  sed -i.bak -E 's#"postinstall": *"[^"]*"#"postinstall": "patch-package"#' package.json
  rm package.json.bak
fi

# 3. Stage & commit
echo "Staging and committing patch and package files…"
git add patches/next+canary.patch package.json package-lock.json
git commit -m "chore: setup patch-package for next+canary.patch"

echo "✅ Step 5 automated: patch-package is wired up and committed."

