# dotfiles

![Ghostty](https://img.shields.io/badge/terminal-Ghostty-8AADF4?style=flat-square&logo=terminal&logoColor=24273A)
![Starship](https://img.shields.io/badge/prompt-Starship-DD7878?style=flat-square&logo=starship&logoColor=ffffff)
![Fish](https://img.shields.io/badge/shell-Fish-179299?style=flat-square&logo=fishshell&logoColor=ffffff)
![macOS](https://img.shields.io/badge/OS-macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Catppuccin](https://img.shields.io/badge/theme-Catppuccin_Latte-EF9F76?style=flat-square&logo=ui3&logoColor=4C4F69)
![Nerd Font](https://img.shields.io/badge/font-JetBrainsMono_Nerd-8839EF?style=flat-square&logo=typography&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-40A02B?style=flat-square)

My macOS terminal setup: **Ghostty + Starship (Catppuccin Powerline Latte) + Fish**. Nerd Font throughout.

## What's inside

| Path | Target | Notes |
|------|--------|-------|
| `ghostty/config` | `~/.config/ghostty/config` | JetBrainsMono Nerd, Catppuccin Latte/Mocha auto, Quake dropdown, `fish` login shell, splits + lazygit/yazi popups |
| `starship/starship.toml` | `~/.config/starship.toml` | `catppuccin-powerline` preset, `palette = 'catppuccin_latte'` |
| `fish/` | `~/.config/fish/` | `config.fish` + `conf.d/` + `functions/` + `completions/` — starship/zoxide/fzf init, eza abbrs, vi bindings |

## Requirements

- macOS + [Homebrew](https://brew.sh)
- [Ghostty](https://ghostty.org), [Fish](https://fishshell.com), [Starship](https://starship.rs)
- JetBrainsMono Nerd Font: `brew install --cask font-jetbrains-mono-nerd-font`
- CLI tools: `brew install eza zoxide fzf lazygit yazi fd bat`

## Install

```sh
git clone https://github.com/seyhunak/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` backs up existing configs to `*.bak.<timestamp>`, then symlinks this repo into `~/.config/`. Reload Ghostty with `Cmd+Shift+,` and open a new tab.

## Key bits

- **Ghostty:** `Cmd+D` / `Cmd+Shift+D` splits, `Cmd+Alt+arrows` navigate, `Cmd+G` lazygit, `Cmd+Shift+O` yazi, `Ctrl+`` Quake terminal
- **Starship:** Powerline segments — OS → user → directory → git → lang versions → conda → time → `❯`
- **Fish:** `ls`/`ll` via eza, `g` lazygit, `v` nvim, `y` yazi, greeting off, `fish_vi_key_bindings`

## License

MIT — see [LICENSE](LICENSE).
