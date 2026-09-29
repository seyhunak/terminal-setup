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

## What's inside

| Path | Target | Notes |
|------|--------|-------|
| `ghostty/config` | `~/.config/ghostty/config` | JetBrainsMono Nerd, Catppuccin Latte/Mocha auto, Quake dropdown, `fish` login shell, splits + lazygit/yazi popups, `Cmd+Shift+A` agent layout |
| `starship/starship.toml` | archived, see [starship/README.md](starship/README.md) | old hand-rolled prompt, kept for reference only — nothing links or reads it |
| `stellar` | `~/.config/starship.toml` -> `~/.config/stellar/a3chron/ctp-blue/1.1.toml` | `stellar apply a3chron/ctp-blue`, completions generated into `~/.config/fish/completions/` |
| `fish/` | `~/.config/fish/` | starship/zoxide/fzf/mise/direnv/asdf init, eza abbrs, agent abbrs (`oc/cc/cx/cr`), `op-env`, `agent-new`, vi bindings |
| `tmux/tmux.conf` | `~/.tmux.conf` | Truecolor for Ghostty, vi copy, 100k history, Catppuccin Latte status |
| `scripts/` | on PATH via fish | `agent-layout.sh` (editor/agent/server tmux session), `git-worktree-add.sh` (isolated worktree per agent) |
| `opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` | Read-only shell allowlist, deny rules for credential paths, filesystem + GitHub (opt-in) MCP, secrets from env |
| `claude/settings.shared.json` | template for `~/.claude/settings.json` | Safe permission baseline with credential deny rules (live hooks untouched) |
| `git/gitconfig.extra` | included via `include.path` | delta pager, `push.autoSetupRemote`, rerere, `main` default |
| `git/hooks/pre-commit` | copy to `.git/hooks/` per repo | Blocks `ghp_/sk-/AKIA` + private-key commits |
| `AGENTS.md` | copy into agent-driven repos | Environment / secrets / workflow / boundaries |
| `.env.example` | copy to `.env` (fill via `op inject`) | `GITHUB_TOKEN`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` as `op://` refs |

## Requirements

macOS with Homebrew. `./install.sh` runs `brew bundle` from `Brewfile` (fish, starship, tmux, nvim, git, delta, direnv, mise, asdf, eza, zoxide, fzf, lazygit, yazi, Ghostty, JetBrainsMono Nerd, 1Password CLI, …) plus the stellar installer (`~/.local/bin/stellar`) and applies `a3chron/ctp-blue`.

## Install

```sh
git clone https://github.com/seyhunak/terminal-setup.git
cd terminal-setup
./install.sh
```

The repo can live anywhere. `install.sh` resolves its own location and derives every symlink from it, so moving or renaming the clone is a non-event: just re-run `./install.sh` and it repairs the symlinks that still point at the old path. Stale symlinks are detected and replaced; real files are backed up to `*.bak.<timestamp>`.

Starship is managed by stellar (`stellar apply a3chron/ctp-blue`), not symlinked. Generated fish completions are written to `~/.config/fish/completions/`, not into the repo, so installs never leave the working tree dirty.

Reload Ghostty with `Cmd+Shift+,` and open a new tab.

## Agentic workflow

```fish
al                                  # tmux session `agent`: editor / agent / server
agent-layout.sh myproj claude        # custom session + agent command
an my-feature                       # .worktrees/my-feature + tmux window (parallel-safe)
wt my-feature origin/main            # same, explicit base branch
op-env .env -- opencode              # secrets from 1Password, never exported
```

- One agent per worktree/branch — never two agents on one branch.
- Worktrees live in `.worktrees/` and are added to `.git/info/exclude` on creation, so they never show up in the parent repo's `git status` without touching its tracked `.gitignore`.
- `mise` / `direnv` / `docker` no longer shown inline (not in upstream `ctp-blue`; re-add via local stellar overlay if wanted).
- Diffs via `delta`; secret-looking commits blocked by the `pre-commit` hook (`cp git/hooks/pre-commit .git/hooks/pre-commit` per repo).

## Key bits

- **Ghostty:** `Cmd+D` / `Cmd+Shift+D` splits, `Cmd+Alt+arrows` navigate, `Cmd+G` lazygit, `Cmd+Shift+O` yazi, `Cmd+Shift+A` agent tmux layout, `Ctrl+`` Quake terminal
- **Starship (stellar `a3chron/ctp-blue@1.1`, `catppuccin_mocha`):** 3-line box — shell/nix/memory + node/python/go/ocaml → user/host/dir/git/cmd-duration → battery + `──╌╌`. Old powerline config archived; `mise`/`direnv`/`docker` segments not in upstream theme.
- **Fish:** `ls`/`ll` via eza, `g` lazygit, `v` nvim, `y` yazi, `oc/ocr/cc/ccr/cx/cr` agents, `opr` 1Password runner, `al`/`wt`/`an` agentic workflows, greeting off, `fish_vi_key_bindings`
- **Secrets:** `cat`/`head`/`tail` are allowed read-only, but explicit `deny` rules for `.env`, `*.pem`, `*.key`, `id_rsa*`, `~/.ssh/`, `~/.aws/`, `~/.netrc` and `~/.config/gh/hosts.yml` sit on top in both the opencode and Claude baselines. `external_directory` denies by default.

## CI

`.github/workflows/ci.yml` runs on every push to `main` and every PR:

- `shellcheck` over `install.sh`, `scripts/*.sh`, `git/hooks/pre-commit`
- `fish --no-execute` over every `.fish` file
- JSON/JSONC parse check on the opencode and Claude configs
- `brew bundle` sanity check
- A guard against reintroducing a hardcoded clone path
- An installer dry run that asserts every symlink resolves and `include.path` points at the checkout

## License

MIT — see [LICENSE](LICENSE).
