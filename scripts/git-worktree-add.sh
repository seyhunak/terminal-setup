#!/usr/bin/env bash
# git-worktree-add.sh — isolated worktree per parallel agent.
# Usage: git-worktree-add.sh <name> [base-branch]
# Creates .worktrees/<name> on new branch <name>, prints its path.
set -euo pipefail

NAME="${1:?usage: git-worktree-add.sh <name> [base-branch]}"
BASE="${2:-main}"

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
git worktree add -b "$NAME" "$WT_DIR" "$BASE" 1>&2
printf '%s\n' "$WT_DIR"
