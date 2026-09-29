#!/usr/bin/env bash
# git-worktree-add.sh — isolated worktree per parallel agent.
# Usage: git-worktree-add.sh <name> [base-branch]
# Creates .worktrees/<name> on new branch <name>, prints its path on stdout.
set -euo pipefail

NAME="${1:?usage: git-worktree-add.sh <name> [base-branch]}"
BASE="${2:-main}"

if [[ ! "$NAME" =~ ^[A-Za-z0-9._/-]+$ ]] || [[ "$NAME" == *..* ]]; then
  echo "error: invalid worktree name '$NAME' (allowed: letters, digits, . _ / -)" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: not inside a git repo" >&2
  exit 1
}
cd "$REPO_ROOT"

# Base must exist locally or remotely; fall back to current HEAD.
if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  if git rev-parse --verify "origin/$BASE" >/dev/null 2>&1; then
    BASE="origin/$BASE"
  else
    echo "warning: base '$BASE' not found, using HEAD" >&2
    BASE="HEAD"
  fi
fi

WT_DIR="$REPO_ROOT/.worktrees/$NAME"
if [[ -e "$WT_DIR" ]]; then
  echo "error: $WT_DIR already exists" >&2
  exit 1
fi
if git show-ref --verify --quiet "refs/heads/$NAME"; then
  echo "error: branch $NAME already exists" >&2
  exit 1
fi

mkdir -p "$REPO_ROOT/.worktrees"
# Keep agent worktrees out of the parent's status output, without touching the
# repo's tracked .gitignore.
grep -qxF '.worktrees/' "$REPO_ROOT/.git/info/exclude" 2>/dev/null ||
  echo '.worktrees/' >>"$REPO_ROOT/.git/info/exclude"

git worktree add -b "$NAME" "$WT_DIR" "$BASE" 1>&2
printf '%s\n' "$WT_DIR"
