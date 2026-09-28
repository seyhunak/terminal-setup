#!/usr/bin/env bash
# dotfiles installer — macOS / Ghostty + Starship + Fish + agentic dev
# Installs deps (brew bundle), backs up existing configs, symlinks repo into ~/.config/
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d-%H%M%S)"

link_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "backup: $dest -> ${dest}${BACKUP_SUFFIX}"
    mv "$dest" "${dest}${BACKUP_SUFFIX}"
  elif [[ -L "$dest" ]]; then
    rm "$dest"
  fi
  ln -sf "$src" "$dest"
  echo "link: $dest -> $src"
}

if command -v brew >/dev/null 2>&1; then
  echo "==> brew bundle"
  brew bundle --file="$DOTFILES_DIR/Brewfile" || echo "brew bundle had issues — continuing"
else
  echo "brew not found — skipping Brewfile (install https://brew.sh first)"
fi

link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"

mkdir -p "$HOME/.config/fish"
for entry in config.fish conf.d functions completions; do
  if [[ -e "$DOTFILES_DIR/fish/$entry" ]]; then
    link_file "$DOTFILES_DIR/fish/$entry" "$HOME/.config/fish/$entry"
  fi
done

chmod +x "$DOTFILES_DIR/scripts/"*.sh
fish_add_path="$HOME/dotfiles/scripts"
echo "ensure ~/dotfiles/scripts is on PATH (fish config already adds it)"

if command -v git >/dev/null 2>&1; then
  git config --global include.path "$DOTFILES_DIR/git/gitconfig.extra" 2>/dev/null || true
  echo "git include.path -> $DOTFILES_DIR/git/gitconfig.extra"
fi

echo "done. Notes:"
echo "- Secrets: use 1Password refs (.env.example). Never commit .env."
echo "- Claude settings: copy claude/settings.shared.json -> ~/.claude/settings.json if wanted (live hooks kept by default)."
echo "- Per-repo secret hook: cp git/hooks/pre-commit .git/hooks/pre-commit"
echo "Reload Ghostty (Cmd+Shift+,) and open a new tab."
