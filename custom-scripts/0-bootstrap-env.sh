#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REMOTE="upstream"
UPSTREAM_URL="https://github.com/vercel/next.js.git"
SCRIPT_BRANCH="infra/custom-scripts"

echo "🔧 Checking for upstream remote..."
if ! git remote get-url "$UPSTREAM_REMOTE" &>/dev/null; then
  echo "➕ Adding upstream remote..."
  git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
else
  echo "✅ Upstream remote already configured."
fi

echo "🔄 Fetching latest from upstream..."
git fetch "$UPSTREAM_REMOTE" --tags

echo "🔄 Fetching latest from origin..."
git fetch origin "$SCRIPT_BRANCH"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "$SCRIPT_BRANCH" ]]; then
  echo "❌ You are on '$CURRENT_BRANCH'. Please switch to '$SCRIPT_BRANCH' before running the release pipeline."
  exit 1
fi

echo "🔍 Verifying local '$SCRIPT_BRANCH' is up to date..."
LOCAL_HASH=$(git rev-parse "$SCRIPT_BRANCH")
REMOTE_HASH=$(git rev-parse "origin/$SCRIPT_BRANCH")

if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
  echo "⚠️ Local '$SCRIPT_BRANCH' is behind origin. Consider pulling latest changes:"
  echo "   git pull origin $SCRIPT_BRANCH"
  exit 1
fi

echo "✅ Environment bootstrap complete. You're on '$SCRIPT_BRANCH' and up to date."

