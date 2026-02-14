#!/usr/bin/env bash
set -euo pipefail

ROOT="/srv/livraone/livraone-core"
EVIDENCE="/tmp/livraone-preflight"

mkdir -p "$EVIDENCE"
cd "$ROOT"

# Ensure .vscode ignored
if ! grep -q '^\.vscode/' .gitignore; then
  echo ".vscode/" >> .gitignore
fi

# Remove untracked .vscode
if [ -d ".vscode" ]; then
  git clean -fd ".vscode"
fi

git status --short | tee "$EVIDENCE/pre-clean.status.txt"

if git ls-files --others --exclude-standard | grep -q '^ops/'; then
  git add ops/ .gitignore
  if git diff --staged --quiet; then
    echo "No changes to commit" | tee "$EVIDENCE/pre-clean.commit.log"
  else
    git commit -m "chore(ops): add runners and ignore vscode" | tee "$EVIDENCE/pre-clean.commit.log"
  fi
fi

git status --short | tee "$EVIDENCE/post-clean.status.txt"
[ -s "$EVIDENCE/post-clean.status.txt" ] && {
  echo "FAIL: repository not clean" >&2
  cat "$EVIDENCE/post-clean.status.txt" >&2
  exit 1
}
