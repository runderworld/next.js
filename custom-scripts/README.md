# 🛠️ Custom Scripts for Patched Next.js Workflow

This directory contains a reproducible automation pipeline for maintaining a patched version of Next.js using your fork. Scripts are numbered to indicate the recommended execution order, and a master script is provided for one-click orchestration.

---

## 🚀 Workflow Overview

1. **Bootstrap environment** — ensure upstream remote is configured and tags are fetched
2. **Rebase onto upstream tag** — apply patch commits on top of a selected upstream version
3. **Build the patched distribution** — compile Next.js once after patching
4. **Verify patch integrity** — confirm that the patch was applied correctly
5. **Publish to internal registry** — push the dist-only build to your npm scope or registry
6. **Tag the release** — version and push the patched build for traceability

---

## 📂 Scripts

| Script                              | Purpose                                                                 |
|-------------------------------------|-------------------------------------------------------------------------|
| `0-bootstrap-env.sh`                | Set up upstream remote and fetch latest tags                           |
| `1-rebase-and-patch.sh`             | Create `release/<tag>-patched` branch and cherry-pick patch commits    |
| `2-build-dist.sh`                   | Build Next.js after patching                                           |
| `3-publish-patched-package.sh`      | Publish the dist-only version to your internal registry                |
| `4-verify-patch-integrity.sh`       | Confirm that the patch was applied correctly                           |
| `5-tag-release.sh`                  | Tag and push the patched release                                       |
| `run-patched-release.sh`            | Master script that runs the full pipeline with optional `--dry-run`    |

---

## 🧪 Usage

### 🔁 Full Release

```bash
bash custom-scripts/run-patched-release.sh
```

### 🧪 Dry Run (no publish, no tag)

```bash
bash custom-scripts/run-patched-release.sh --dry-run
```

### 🔧 Manual Execution (step-by-step)

```bash
bash custom-scripts/0-bootstrap-env.sh
bash custom-scripts/1-rebase-and-patch.sh
bash custom-scripts/2-build-dist.sh
bash custom-scripts/4-verify-patch-integrity.sh
bash custom-scripts/3-publish-patched-package.sh
bash custom-scripts/5-tag-release.sh
```

## 🧠 Notes
- Patch commits are hardcoded in `1-rebase-and-patch.sh`. Update them as needed.
- `release/<tag>-patched` branches are force-pushed for each release.
- `4-verify-patch-integrity.sh` checks for a fingerprint string in the built output.
- Publishing assumes you're authenticated with your internal npm registry.
- Dry-run mode skips publish and tag but still verifies patch integrity.
