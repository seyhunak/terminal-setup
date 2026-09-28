# dotfiles

![Ghostty](https://img.shields.io/badge/terminal-Ghostty-8AADF4?style=flat-square&logo=terminal&logoColor=24273A)
![Starship](https://img.shields.io/badge/prompt-Starship-DD7878?style=flat-square&logo=starship&logoColor=ffffff)
![Fish](https://img.shields.io/badge/shell-Fish-179299?style=flat-square&logo=fishshell&logoColor=ffffff)
![macOS](https://img.shields.io/badge/OS-macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Catppuccin](https://img.shields.io/badge/theme-Catppuccin_Latte-EF9F76?style=flat-square&logo=ui3&logoColor=4C4F69)
![Nerd Font](https://img.shields.io/badge/font-JetBrainsMono_Nerd-8839EF?style=flat-square&logo=typography&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-40A02B?style=flat-square)
![tmux](https://img.shields.io/badge/sessions-tmux-40A02B?style=flat-square&logo=tmux&logoColor=white)
![1Password](https://img.shields.io/badge/secrets-1Password-0094F5?style=flat-square&logo=1password&logoColor=white)

My macOS terminal setup: **Ghostty + Starship (stellar `a3chron/ctp-blue`) + Fish**, wired for agentic dev (opencode / Claude Code / Codex / Crush). Nerd Font throughout.

## What's inside

| Path | Target | Notes |
|------|--------|-------|
| `ghostty/config` | `~/.config/ghostty/config` | JetBrainsMono Nerd, Catppuccin Latte/Mocha auto, Quake dropdown, `fish` login shell, splits + lazygit/yazi popups, `Cmd+Shift+A` agent layout |
| `starship/starship.toml` | archived (pre-stellar backup, also `stellar apply seyhunakyurek/backup@1.0`) | old `catppuccin-powerline` hand-rolled prompt, replaced by stellar |
| `stellar` | `~/.config/starship.toml` -> `~/.config/stellar/a3chron/ctp-blue/1.1.toml` | `stellar apply a3chron/ctp-blue`, completions in `fish/completions/stellar.fish` |
| `fish/` | `~/.config/fish/` | starship/zoxide/fzf/mise/direnv/asdf init, eza abbrs, agent abbrs (`oc/cc/cx/cr`), `op-env`, `agent-new`, vi bindings |
| `tmux/tmux.conf` | `~/.tmux.conf` | Truecolor for Ghostty, vi copy, 100k history, Catppuccin Latte status |
| `scripts/` | on PATH via fish | `agent-layout.sh` (editor/agent/server tmux session), `git-worktree-add.sh` (isolated worktree per agent) |
| `opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` | Read-only shell allowlist, filesystem + GitHub (opt-in) MCP, secrets from env |
| `claude/settings.shared.json` | template for `~/.claude/settings.json` | Safe permission baseline (live hooks untouched) |
| `git/gitconfig.extra` | included via `include.path` | delta pager, `push.autoSetupRemote`, rerere, `main` default |
| `git/hooks/pre-commit` | copy to `.git/hooks/` per repo | Blocks `ghp_/sk-/AKIA` + private-key commits |
| `AGENTS.md` | copy into agent-driven repos | Environment / secrets / workflow / boundaries |
| `.env.example` | copy to `.env` (fill via `op inject`) | `GITHUB_TOKEN`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` as `op://` refs |

## Requirements

One command after cloning: `./install.sh` runs `brew bundle` from `Brewfile` (fish, starship, tmux, nvim, git, delta, direnv, mise, asdf, eza, zoxide, fzf, lazygit, yazi, Ghostty, JetBrainsMono Nerd, 1Password CLI, …) plus the stellar installer (`~/.local/bin/stellar`) and applies `a3chron/ctp-blue`.

## Install

```sh
git clone https://github.com/seyhunak/terminal-setup.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs `brew bundle`, backs up existing configs to `*.bak.<timestamp>`, then symlinks this repo into `~/.config/` (+ `~/.tmux.conf`, git `include.path`). Starship is managed by stellar (`stellar apply a3chron/ctp-blue`), not symlinked. Reload Ghostty with `Cmd+Shift+,` and open a new tab.

## Agentic workflow

```fish
agent-layout.sh                # tmux session `agent`: editor / agent / server
agent-layout.sh myproj Claude  # custom session + agent command
agent-new my-feature           # .worktrees/my-feature + tmux window (parallel-safe)
op-env .env -- opencode        # secrets from 1Password, never exported
```

- One agent per worktree/branch — never two agents on one branch.
- `mise` / `direnv` / `docker` no longer shown inline (not in upstream `ctp-blue`; re-add via local stellar overlay if wanted).
- Diffs via `delta`; secret-looking commits blocked by `pre-commit` hook.

## Key bits

- **Ghostty:** `Cmd+D` / `Cmd+Shift+D` splits, `Cmd+Alt+arrows` navigate, `Cmd+G` lazygit, `Cmd+Shift+O` yazi, `Cmd+Shift+A` agent tmux layout, `Ctrl+`` Quake terminal
- **Starship (stellar `a3chron/ctp-blue@1.1`, `catppuccin_mocha`):** 3-line box — shell/nix/memory + node/python/go/ocaml → user/host/dir/git/cmd-duration → battery + `──╌╌`. Old powerline config archived; `mise`/`direnv`/`docker` segments not in upstream theme.
- **Fish:** `ls`/`ll` via eza, `g` lazygit, `v` nvim, `y` yazi, `oc/ocr/cc/ccr/cx/cr` agents, `opr` 1Password runner, greeting off, `fish_vi_key_bindings`

## License

MIT — see [LICENSE](LICENSE).
