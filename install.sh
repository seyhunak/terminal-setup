#!/usr/bin/env bash
# dotfiles installer — macOS / Ghostty + Starship + Fish
# Backs up existing configs, then symlinks repo files into ~/.config/
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

link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

mkdir -p "$HOME/.config/fish"
for entry in config.fish conf.d functions completions; do
  if [[ -e "$DOTFILES_DIR/fish/$entry" ]]; then
    link_file "$DOTFILES_DIR/fish/$entry" "$HOME/.config/fish/$entry"
  fi
done

echo "done. Reload Ghostty (Cmd+Shift+,) and open a new tab."
