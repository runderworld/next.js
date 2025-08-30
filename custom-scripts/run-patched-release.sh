#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🧪 Dry run mode enabled: will NOT publish or tag."
fi

SCRIPT_BRANCH="infra/custom-scripts"
WORKTREE_DIR=".release-worktree"

# Ensure we're on the automation branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "$SCRIPT_BRANCH" ]]; then
  echo "❌ You must run this script from '$SCRIPT_BRANCH'. Currently on '$CURRENT_BRANCH'."
  exit 1
fi

# Bootstrap environment
bash custom-scripts/0-bootstrap-env.sh

# Prompt for upstream tag
DEFAULT_TAG="v15.5.2"
read -rp "🏷️  Enter the upstream tag to base your release on (default: $DEFAULT_TAG): " UP_TAG
UP_TAG="${UP_TAG:-$DEFAULT_TAG}"

if [[ -z "$UP_TAG" ]]; then
  echo "❌ No tag provided. Aborting."
  exit 1
fi

echo "📌 Using upstream tag: $UP_TAG"

RELEASE_BRANCH="release/${UP_TAG}-patched"
RELEASE_TAG="${UP_TAG}-patched"
SCRIPT_TAG="scripts/${UP_TAG}-patch"

# Check for existing tags
for TAG in "$RELEASE_TAG" "$SCRIPT_TAG"; do
  if git rev-parse "$TAG" &>/dev/null; then
    echo "❌ Tag '$TAG' already exists. Aborting."
    exit 1
  fi
done

# Clean up any previous worktree
rm -rf "$WORKTREE_DIR"
git worktree prune

# Create a detached worktree for the release branch
echo "📦 Creating worktree for $RELEASE_BRANCH..."
git worktree add "$WORKTREE_DIR" "$UP_TAG"
cd "$WORKTREE_DIR"

# Apply patches
bash ../custom-scripts/1-rebase-and-patch.sh "$UP_TAG"

# Build
bash ../custom-scripts/2-build-dist.sh

# Verify and publish
bash ../custom-scripts/3-publish-and-verify.sh $([[ "$DRY_RUN" == true ]] && echo "--no-push")

# Tag release
if $DRY_RUN; then
  echo "✅ Dry run complete. Skipping tag."
else
  bash ../custom-scripts/4-tag-release.sh "$UP_TAG"
fi

# Cleanup
cd ..
git worktree remove "$WORKTREE_DIR"

echo "🎉 Release pipeline complete."

