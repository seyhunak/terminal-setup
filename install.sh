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
# Starship is managed by stellar (https://stellar.a3chron.dev), not symlinked.
# Old hand-rolled config kept as starship/starship.toml (also backed up as seyhunakyurek/backup@1.0).
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

# stellar (starship theme manager) + ctp-blue theme
export PATH="$HOME/.local/bin:$PATH"
if ! command -v stellar >/dev/null 2>&1; then
  echo "==> installing stellar"
  curl -fsSL https://raw.githubusercontent.com/a3chron/stellar/main/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"
stellar apply a3chron/ctp-blue
stellar completion fish >"$DOTFILES_DIR/fish/completions/stellar.fish"
echo "stellar theme -> $(stellar current 2>/dev/null | head -n 5 | tr '\n' ' ')"

echo "done. Notes:"
echo "- Secrets: use 1Password refs (.env.example). Never commit .env."
echo "- Claude settings: copy claude/settings.shared.json -> ~/.claude/settings.json if wanted (live hooks kept by default)."
echo "- Per-repo secret hook: cp git/hooks/pre-commit .git/hooks/pre-commit"
echo "Reload Ghostty (Cmd+Shift+,) and open a new tab."
