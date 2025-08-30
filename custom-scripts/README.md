# 🛠️ Custom Scripts for Patched Next.js Workflow

This directory contains a reproducible automation pipeline for maintaining a patched version of Next.js using your fork. Scripts are numbered to indicate the recommended execution order, and a master script is provided for one-click orchestration.

---

## 🚀 Workflow Overview

1. **Bootstrap environment** — ensure upstream remote is configured and tags are fetched
2. **Rebase onto upstream tag** — apply patch commits on top of a selected upstream version
3. **Build the patched distribution** — compile Next.js once after patching
4. **Verify and publish** — confirm that the patch was applied correctly and publish to your npm scope
5. **Tag the release** — version and push the patched build for traceability

---

## 📂 Scripts

| Script                              | Purpose                                                                 |
|-------------------------------------|-------------------------------------------------------------------------|
| `0-bootstrap-env.sh`                | Set up upstream remote and fetch latest tags                           |
| `1-rebase-and-patch.sh`             | Create `release/<tag>-patched` branch and cherry-pick patch commits    |
| `2-build-dist.sh`                   | Build Next.js after patching                                           |
| `3-publish-and-verify.sh`           | Verify patch fingerprint and publish to npm                            |
| `4-tag-release.sh`                  | Tag and push the patched release                                       |
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
bash custom-scripts/3-publish-and-verify.sh
bash custom-scripts/4-tag-release.sh
```

---

## 🧠 Notes
- Patch commits are hardcoded in `1-rebase-and-patch.sh`. Update them as needed.
- `release/<tag>-patched` branches are force-pushed for each release.
- Fingerprint verification is embedded in `3-publish-and-verify.sh` and checks for a unique string in the built output.
- Publishing assumes you're authenticated with your scoped npm registry and have set `"publishConfig.access": "public"` in `package.json`.
- Dry-run mode skips publish and tag but still runs the full pipeline up to verification.

---
