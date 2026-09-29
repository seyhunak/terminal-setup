# AGENTS.md — shared agent instructions (template)

Copy this file (or sections) into any repo you drive with coding agents.
It matches this terminal setup: Fish + Ghostty + Starship + tmux + worktrees.

## Agents

Seven CLIs are wired in, all with safe defaults (no `--yolo`, no
`--dangerously-bypass-approvals`): `oc`/`ocr` opencode, `cc`/`ccr` claude,
`cx`/`cxr` codex, `co` copilot, `cn` cline, `ad` aider, `cr` crush, `gem` gemini.
A shortcut is only registered if its binary exists.

`cx` runs `codex -p dotfiles`, a profile layered on top of `~/.codex/config.toml`
that sets `sandbox_mode = "workspace-write"` and `approval_policy = "on-request"`.

## Environment

- Shell is Fish (`/opt/homebrew/bin/fish`). Use Fish syntax, not bash, for one-liners.
- Terminal is Ghostty; prompt is Starship via stellar, theme `a3chron/ctp-blue` (catppuccin_mocha). See `starship/README.md`.
- Persistent work happens in tmux session `agent` (`agent-layout.sh` / `al`): `editor` / `agent` / `server` windows.
- Parallel agents use isolated worktrees: `git-worktree-add.sh <name> [base]` → `.worktrees/<name>`. Never two agents on one branch. Worktrees are excluded via `.git/info/exclude`, not the repo's `.gitignore`.
- Tool versions via mise/asdf + direnv (`.envrc` + `.tool-versions`). Respect them; don't `brew install` a different major.

## Secrets

- Never print, commit, or paste tokens. Secrets come from 1Password at runtime:
  `op run --env-file=.env -- <agent-cmd>` or `op-env .env -- <agent-cmd>` (Fish).
- `.env` / `.envrc` with real values are never committed. `.env.example` documents keys.
- Credential paths are denied in the opencode, Claude, and codex baselines. They are **not** enforced by copilot (tested: `deniedTools` and `--deny-tool` did not block a local `.env` read in `-p` mode), and cline and crush have no baseline at all. Don't rely on a permission list as the only control — inject secrets per command.

## Workflow

1. Read `README.md` + this file before coding. Check `Brewfile` / `package.json` for the real toolchain.
2. Search with `rg` / `fd`, not `find` / `grep -r`. Read files fully before editing.
3. Plan before big edits: state hypotheses, verify with cheap checks, then write code.
4. Verify every change by running it: relevant tests, `git status -sb`, `git diff --stat`.
5. Keep diffs small and atomic. One concern per commit. Conventional commits (`feat:`, `fix:`, `chore:`).
6. In this repo, also run the CI gates locally: `shellcheck install.sh scripts/*.sh git/hooks/pre-commit` and `fish --no-execute` on each `.fish` file.

## Boundaries

- Read-only shell (`git status/diff/log`, `ls`, `rg`, `fd`) is free.
- Ask before: editing files outside the task scope, running migrations/deploys, force-pushing, `rm -rf`, network writes.
- After work: report files changed, tests run + result, and any follow-ups. No superlatives, just facts.
