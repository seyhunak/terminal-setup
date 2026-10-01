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

**Tools wired in** — every CLI below is declared in `Brewfile` and initialised in fish (or deliberately deferred; see the table):

![atuin](https://img.shields.io/badge/history-atuin-F26D5D?style=flat-square&logo=rust&logoColor=white)
![fzf](https://img.shields.io/badge/fuzzy_finder-fzf-6BBF8A?style=flat-square)
![zoxide](https://img.shields.io/badge/cd-zoxide-EB8A3E?style=flat-square)
![mise](https://img.shields.io/badge/runtimes-mise-6C7BFF?style=flat-square)
![eza](https://img.shields.io/badge/ls-eza-4C9A8C?style=flat-square)
![bat](https://img.shields.io/badge/cat-bat-8F8F8F?style=flat-square)
![ripgrep](https://img.shields.io/badge/grep-ripgrep-F4554A?style=flat-square)
![fd](https://img.shields.io/badge/find-fd-4C9A8C?style=flat-square)
![lazygit](https://img.shields.io/badge/git-lazygit-D74B4C?style=flat-square)
![yazi](https://img.shields.io/badge/files-yazi-3FA9F5?style=flat-square)
![jq](https://img.shields.io/badge/json-jq-3B3B98?style=flat-square)
![direnv](https://img.shields.io/badge/env-direnv-8AB4F8?style=flat-square)
![uv](https://img.shields.io/badge/pip-uv-5A6DD6?style=flat-square)
![fnm](https://img.shields.io/badge/node-fnm-5FA04E?style=flat-square)
![pyenv](https://img.shields.io/badge/python-pyenv-3A8B3C?style=flat-square)
![thefuck](https://img.shields.io/badge/fix_your_cmd-thefuck-D65F5F?style=flat-square)
![htop](https://img.shields.io/badge/processes-htop-5FA04E?style=flat-square)
![nvim](https://img.shields.io/badge/editor-Neovim-57A143?style=flat-square&logo=neovim&logoColor=white)

**Agents wired in** — every one has a shortcut; the badge colour is the strength of its permission boundary (green = sandboxed/enforced, amber = flags-only, grey = no baseline):

![opencode](https://img.shields.io/badge/opencode-sandboxed-F59E0B?style=flat-square&logo=opencode&logoColor=white)
![claude](https://img.shields.io/badge/claude_code-sandboxed-D97757?style=flat-square&logo=anthropic&logoColor=white)
![codex](https://img.shields.io/badge/codex-sandboxed-10A37F?style=flat-square&logo=openai&logoColor=white)
![copilot](https://img.shields.io/badge/copilot-CLI_flags_only-6E40C9?style=flat-square&logo=github&logoColor=white)
![cline](https://img.shields.io/badge/cline-CLI_flags_only-8B5CF6?style=flat-square&logo=cline&logoColor=white)
![aider](https://img.shields.io/badge/aider-no_auto_commit-A3A3A3?style=flat-square)
![crush](https://img.shields.io/badge/crush-no_baseline-6E7681?style=flat-square)

My macOS terminal setup: **Ghostty + Starship (stellar `a3chron/ctp-blue`) + Fish**, wired for agentic dev across seven agent CLIs. Nerd Font throughout.

## Agents

| abbr | CLI | permission baseline | notes |
|------|-----|--------------------|-------|
| `oc` / `ocr` | opencode | ✅ `~/.config/opencode/opencode.jsonc` | read-only allowlist + credential denies, symlinked |
| `cc` / `ccr` | claude | ✅ `claude/settings.shared.json` | merge-only; live hooks and plugins stay yours |
| `cx` / `cxr` | codex | ✅ `~/.codex/dotfiles.config.toml` | profile layer via `codex -p dotfiles`; sandbox `workspace-write`, approval `on-request` |
| `co` | copilot | ⚠️ `copilot/settings.shared.json` | merge-only; `allowedTools`/`deniedTools` exist but were **not** enforced in `-p` mode in testing |
| `cn` | cline | — | wrapper in `fish/functions/cline.fish` re-signs the macOS binary; no config file to baseline |
| `ad` | aider | ✅ `~/.aider.conf.yml` | auto-commits off, dirty-commits off, no analytics |
| `cr` | crush | — | config is provider-only (`crush.json` has just `providers`); permissions are interactive prompts. Avoid `--yolo` |
| `gem` | gemini | — | shortcut registers only if the binary is present |

Every shortcut is registered **only when its binary exists**, so a fresh clone on a machine without aider doesn't collect dead abbrs.

**The copilot caveat is worth reading.** I tested `deniedTools` and `--deny-tool` against a local `.env` and the read went through in `-p` mode. Treat copilot's permission list as a guardrail for interactive use, not a hard boundary. The reliable control for every tool is the same: keep secrets out of the working tree and inject them per command with `op run --env-file=.env -- <agent>`.

## What's inside

| Path | Target | Notes |
|------|--------|-------|
| `ghostty/config` | `~/.config/ghostty/config` | JetBrainsMono Nerd, Catppuccin Latte/Mocha auto, Quake dropdown, `fish` login shell, splits + lazygit/yazi popups, `Cmd+Shift+A` agent layout |
| `starship/starship.toml` | archived, see [starship/README.md](starship/README.md) | old hand-rolled prompt, kept for reference only — nothing links or reads it |
| `stellar` | `~/.config/starship.toml` -> `~/.config/stellar/a3chron/ctp-blue/1.1.toml` | `stellar apply a3chron/ctp-blue`, completions generated into `~/.config/fish/completions/` |
| `fish/` | `~/.config/fish/` | starship/zoxide/fzf/mise/direnv/asdf/atuin init, eza abbrs, agent abbrs (`oc/cc/cx/cr`), `tf`, `proc`, `op-env`, `agent-new`, vi bindings |
| `zsh/zshrc-fish-handoff.zsh` | spliced into `~/.zshrc` between markers | hands interactive zsh to fish, so the agent abbrs work outside Ghostty too. Never symlinks over your `.zshrc`; delete the block to opt out, or `DOTFILES_FISH_HANDOFF=off zsh` one-shot |
| `tmux/tmux.conf` | `~/.tmux.conf` | Truecolor for Ghostty, vi copy, 100k history, Catppuccin Latte status |
| `scripts/` | on PATH via fish | `agent-layout.sh` (editor/agent/server tmux session), `git-worktree-add.sh` (isolated worktree per agent) |
| `opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` | Read-only shell allowlist, deny rules for credential paths, filesystem + GitHub (opt-in) MCP, secrets from env |
| `codex/dotfiles.config.toml` | `~/.codex/dotfiles.config.toml`, used via `cx` | **Profile layer**, not a replacement: `sandbox_mode = "workspace-write"`, `approval_policy = "on-request"`. Your `~/.codex/config.toml` (model, marketplaces, plugins, trust) is untouched |
| `aider/aider.conf.yml` | `~/.aider.conf.yml` | No auto-commits, no dirty-tree commits, no analytics, no update check |
| `claude/settings.shared.json` | merge into `~/.claude/settings.json` | Safe permission baseline with credential deny rules (live hooks/plugins untouched) |
| `copilot/settings.shared.json` | merge into `~/.copilot/settings.json` | Allowed/denied tools and URLs. **Weakest boundary of the six** — see the caveat below |
| `git/gitconfig.extra` | included via `include.path` | delta pager, `push.autoSetupRemote`, rerere, `main` default |
| `git/hooks/pre-commit` | copy to `.git/hooks/` per repo | Blocks `ghp_/sk-/AKIA` + private-key commits |
| `AGENTS.md` | copy into agent-driven repos | Environment / secrets / workflow / boundaries |
| `.env.example` | copy to `.env` (fill via `op inject`) | `GITHUB_TOKEN`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` as `op://` refs |

## Requirements

macOS with Homebrew. `./install.sh` runs `brew bundle` from `Brewfile` (fish, starship, tmux, nvim, git, delta, direnv, mise, asdf, eza, zoxide, fzf, lazygit, yazi, Ghostty, JetBrainsMono Nerd, 1Password CLI, …) plus the stellar installer (`~/.local/bin/stellar`) and applies `a3chron/ctp-blue`.

### Tools

| Tool | Provides | Where |
|------|----------|-------|
| `eza` / `bat` / `fd` / `ripgrep` | `ls`, `cat`, `find`, `grep` | `abbr ls`/`ll` in `fish/config.fish` |
| `zoxide` | smart `cd` | `abbr z`, `zoxide init fish` |
| `fzf` | fuzzy finder | `fzf --fish`, `FZF_DEFAULT_COMMAND` = `fd` |
| `atuin` | shell history + sync | `atuin init fish`, last in `config.fish` so it keeps `ctrl-r` |
| `yazi` / `lazygit` | file manager / git TUI | `abbr y`, `abbr g`, Ghostty `cmd+shift+o` / `cmd+g` |
| `jq` | JSON processor | path only |
| `direnv` | per-directory env | `direnv hook fish`, allowed in Starship |
| `mise` | Node/Python/Ruby/… | **primary** runtime manager, `mise activate fish` |
| `fnm` / `pyenv` | Node / Python | installed, but only initialise when **mise is absent** — otherwise their shims shadow mise's. See `fish/conf.d/fnm.fish`, `pyenv.fish` |
| `uv` | pip, astral-fast | `fish/conf.d/uv.env.fish` |
| `thefuck` | corrects a wrong command | `abbr tf` — **no fish integration**: thefuck 3.32 only generates bash/zsh glue, so `tf <cmd>` prints the fix and no key binding is wired |
| `htop` | process viewer | `abbr proc` (`sudo htop` for all processes) |

`atuin` sync is opt-in and never configured here — run `atuin register` yourself and keep the token in 1Password, not in this repo.

## Install

```sh
git clone https://github.com/seyhunak/terminal-setup.git
cd terminal-setup
./install.sh
```

The repo can live anywhere. `install.sh` resolves its own location and derives every symlink from it, so moving or renaming the clone is a non-event: just re-run `./install.sh` and it repairs the symlinks that still point at the old path. Stale symlinks are detected and replaced; real files are backed up to `*.bak.<timestamp>`.

Starship is managed by stellar (`stellar apply a3chron/ctp-blue`), not symlinked. Generated fish completions are written to `~/.config/fish/completions/`, not into the repo, so installs never leave the working tree dirty.

**Why `oc` was "command not found".** Ghostty and tmux both launch fish directly, but macOS keeps `/bin/zsh` as the login shell, so Terminal.app, VS Code, `ssh` and a hand-typed `zsh` all start in zsh — where the fish `abbr`s do not exist. The installer patches a marked block into `~/.zshrc` that `exec`s fish. It reports the login shell it found and, if fish is missing from `/etc/shells` (it is, on stock macOS), the `chsh` steps to fix that properly. `chsh` needs your password, so it is never run for you.

Reload Ghostty with `Cmd+Shift+,` and open a new tab — or just `exec fish`.

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
- **Fish:** `ls`/`ll` via eza, `g` lazygit, `v` nvim, `y` yazi, `opr` 1Password runner, `al`/`wt`/`an` agentic workflows, greeting off, `fish_vi_key_bindings`
- **Secrets:** `.env` is git-ignored (only `.env.example` is tracked), and both agent baselines that support it deny `read`/`cat`/`head`/`tail` on `.env`, `*.pem`, `*.key`, `id_rsa*`, `~/.ssh/`, `~/.aws/`, `~/.netrc` and `~/.config/gh/hosts.yml`. opencode's `external_directory` denies by default. copilot and cline are the exceptions — see the Agents table.

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
