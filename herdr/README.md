# herdr

Agent-aware terminal multiplexer. Where the rest of this setup is a terminal
emulator plus tmux, herdr is a second multiplexer that understands coding
agents: it reads every pane, tells you which agent is `working`, which is
`blocked` waiting on you, and which is `done`, and its CLI plus socket API are
the same surface agents drive.

Docs: <https://herdr.dev/docs/> · agent guide: <https://herdr.dev/agent-guide.md>

## Install

Not in the `Brewfile` on purpose:

```sh
curl -fsSL https://herdr.dev/install.sh | sh
```

It lands in `~/.local/bin/herdr`, which comes **before** `/opt/homebrew/bin` on
PATH. A Homebrew copy would therefore be shadowed and print a warning on every
`brew` invocation, so the curl install is the one that is kept and `herdr
update` keeps it current.

## Commands

| abbr | runs | what it does |
|------|------|--------------|
| `hd` | `herdr` | launch or attach to the persistent session |
| `hst` | `herdr status` | client + running-server status |
| `hal` | `herdr agent list` | every detected agent and its state |
| `hwl` | `herdr worktree list` | worktree-backed workspaces |

```sh
hd                              # attach to the default session
herdr worktree create --branch fix-auth --base main
herdr worktree list
herdr server reload-config      # apply config edits without restarting
herdr server stop               # actually stop the server
herdr --default-config          # print the full default config
```

Completions are generated from the binary by `install.sh` into
`~/.config/fish/completions/herdr.fish` (never into the repo) and sourced from
`fish/conf.d/herdr.fish`.

## Config

`herdr/config.toml` is symlinked to `~/.config/herdr/config.toml`. A pre-existing
file is backed up, not replaced, and live edits need `herdr server reload-config`.

What the tracked config sets, and why:

- **theme `catppuccin`** — matches Ghostty's Catppuccin Latte/Mocha and the tmux status bar.
- **`default_shell = /opt/homebrew/bin/fish`, `shell_mode = "login"`** — new panes otherwise inherit the launchd agent's `$SHELL`, which is `/bin/zsh` on this machine.
- **`prefix+alt+g` → lazygit popup** — same muscle memory as Ghostty's `Cmd+G`, and a popup (not a split) still lets lazygit take the mouse.
- **`[ui.toast] delivery = "herdr"`** — toast when a background agent needs attention. Without it you go pane by pane hunting for whoever is blocked.

## Agents and worktrees

`herdr worktree` overlaps this repo's own `git-worktree-add.sh`, with two
differences worth knowing:

- herdr creates worktrees under `~/.herdr/worktrees/<repo>/<branch>`; this repo's script uses `.worktrees/` inside the checkout and adds that to `.git/info/exclude`.
- `herdr worktree remove --workspace <id> --force` removes the checkout and the worktree registration but **leaves the git branch behind**. Delete it yourself: `git branch -d <name>`.

Lifecycle integrations (`herdr integration status`) report agent state directly
and are installed for `claude`, `codex`, `opencode` and others. **cline has no
integration** — it is still a valid `herdr agent start --kind cline`, but its
state comes from screen detection rather than a lifecycle hook, so
working/blocked/done is less reliable for it than for the integrated agents.

## tmux and herdr together

They are alternatives, not layers: herdr is a multiplexer like tmux, so nesting
one inside the other is asking for trouble. Use tmux for `al` / `duo`
(`agent-layout.sh`, `agent-duo.sh`) and herdr for agent-state-aware sessions —
pick one per terminal, not both in the same pane. Herdr blocks nested herdr
launches itself; it cannot know you are inside tmux.