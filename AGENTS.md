# AGENTS.md — shared agent instructions (template)

Copy this file (or sections) into any repo you drive with coding agents.
It matches this terminal setup: Fish + Ghostty + Starship + tmux + worktrees.

## Environment

- Shell is Fish (`/opt/homebrew/bin/fish`). Use Fish syntax, not bash, for one-liners.
- Terminal is Ghostty; prompt is Starship Catppuccin Powerline Latte.
- Persistent work happens in tmux session `agent` (`agent-layout.sh`): `editor` / `agent` / `server` windows.
- Parallel agents use isolated worktrees: `git-worktree-add.sh <name> [base]` → `.worktrees/<name>`. Never two agents on one branch.
- Tool versions via mise/asdf + direnv (`.envrc` + `.tool-versions`). Respect them; don't `brew install` a different major.

## Secrets

- Never print, commit, or paste tokens. Secrets come from 1Password at runtime:
  `op run --env-file=.env -- <agent-cmd>` or `op-env .env -- <agent-cmd>` (Fish).
- `.env` / `.envrc` with real values are never committed. `.env.example` documents keys.

## Workflow

1. Read `README.md` + this file before coding. Check `Brewfile` / `package.json` for the real toolchain.
2. Search with `rg` / `fd`, not `find` / `grep -r`. Read files fully before editing.
3. Plan before big edits: state hypotheses, verify with cheap checks, then write code.
4. Verify every change by running it: relevant tests, `git status -sb`, `git diff --stat`.
5. Keep diffs small and atomic. One concern per commit. Conventional commits (`feat:`, `fix:`, `chore:`).

## Boundaries

- Read-only shell (`git status/diff/log`, `ls`, `rg`, `fd`) is free.
- Ask before: editing files outside the task scope, running migrations/deploys, force-pushing, `rm -rf`, network writes.
- After work: report files changed, tests run + result, and any follow-ups. No superlatives, just facts.
