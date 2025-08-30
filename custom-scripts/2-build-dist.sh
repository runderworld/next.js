#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Building Next.js distribution..."
pnpm install
pnpm build

echo "✅ Build complete. Dist artifacts are ready."

