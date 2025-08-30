#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REMOTE="upstream"
PATCH_COMMITS=(
  ed127bb230748d7471b74c16b0532aaf42a0f808
  ea98aea563173245e989ca2af84ad274c979f581
  3017607daab6161721dcdeba286374c7f7725c19
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

echo "🔄 Checking if remote branch '$BRANCH' already exists..."
if git ls-remote --exit-code origin "refs/heads/$BRANCH" &>/dev/null; then
  echo "⚠️ Remote branch '$BRANCH' already exists."
  read -rp "❓ Force-push and overwrite it? [y/N]: " CONFIRM
  if [[ "$CONFIRM" != "y" ]]; then
    echo "🚫 Aborting push."
    exit 1
  fi
  echo "🚀 Force-pushing branch $BRANCH to origin..."
  git push --force --set-upstream origin "$BRANCH"
else
  echo "🚀 Pushing new branch $BRANCH to origin..."
  git push --set-upstream origin "$BRANCH"
fi

echo "✅ Branch $BRANCH is now pushed and tracking origin/$BRANCH."

