#!/usr/bin/env bash
set -euo pipefail

UP_TAG="${1:-}"
if [[ -z "$UP_TAG" ]]; then
  echo "❌ Missing upstream tag. Usage: 4-tag-release.sh <tag>"
  exit 1
fi

RELEASE_BRANCH="release/${UP_TAG}-patched"
RELEASE_TAG="${UP_TAG}-patched"
SCRIPT_BRANCH="infra/custom-scripts"
SCRIPT_TAG="scripts/${UP_TAG}-patch"

echo "🔄 Checking out release branch $RELEASE_BRANCH..."
git checkout "$RELEASE_BRANCH"

# Overwrite existing tags if needed
for TAG in "$RELEASE_TAG" "$SCRIPT_TAG"; do
  if git rev-parse "$TAG" &>/dev/null; then
    echo "⚠️ Tag '$TAG' already exists. Overwriting..."
    git tag -d "$TAG"
    git push origin ":refs/tags/$TAG"
  fi
done

SCRIPT_HASH=$(git rev-parse "$SCRIPT_BRANCH")

echo "🔖 Creating Git tag $RELEASE_TAG on $RELEASE_BRANCH..."
git tag -a "$RELEASE_TAG" -m "Patched release based on upstream $UP_TAG.
Built using custom-scripts@$SCRIPT_HASH from branch '$SCRIPT_BRANCH'."

echo "🚀 Pushing tag $RELEASE_TAG to origin..."
git push origin "$RELEASE_TAG"

echo "🔖 Creating Git tag $SCRIPT_TAG on $SCRIPT_BRANCH..."
git tag -a "$SCRIPT_TAG" "$SCRIPT_HASH" -m "Automation scripts used for release $RELEASE_TAG"

echo "🚀 Pushing tag $SCRIPT_TAG to origin..."
git push origin "$SCRIPT_TAG"

echo "✅ Tagged and pushed: $RELEASE_TAG and $SCRIPT_TAG"

