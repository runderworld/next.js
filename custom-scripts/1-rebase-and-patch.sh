#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REMOTE="upstream"
PATCH_COMMITS=(
  ed127bb230748d7471b74c16b0532aaf42a0f808
  ea98aea563173245e989ca2af84ad274c979f581
  f850e7c99611cc01d18ca912e2c7aa67db2414ab
)

UP_TAG="${1:-}"
if [[ -z "$UP_TAG" ]]; then
  echo "❌ Missing upstream tag. Usage: 1-rebase-and-patch.sh <tag>"
  exit 1
fi

BRANCH="release/${UP_TAG}-patched"

echo "🔍 Fetching latest tags from $UPSTREAM_REMOTE..."
git fetch "$UPSTREAM_REMOTE" --tags

echo "📦 Creating branch $BRANCH from tag $UP_TAG..."
git checkout -B "$BRANCH" "$UP_TAG"

echo "🧩 Cherry-picking patch commits onto $BRANCH..."
for COMMIT in "${PATCH_COMMITS[@]}"; do
  echo "➡️  Cherry-picking $COMMIT"
  git cherry-pick "$COMMIT"
done

echo "🔄 Pushing branch $BRANCH to origin and setting upstream tracking..."
git push --set-upstream origin "$BRANCH"

echo "✅ Branch $BRANCH is now pushed and tracking origin/$BRANCH."

