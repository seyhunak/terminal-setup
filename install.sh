#!/usr/bin/env bash
# dotfiles installer — macOS / Ghostty + Starship + Fish + agentic dev
# Installs deps (brew bundle), backs up existing configs, symlinks repo into ~/.config/
#
# Idempotent and location-independent: the repo can live anywhere, and re-running
# this script repairs symlinks that point at a previous clone location.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d-%H%M%S)"

link_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" ]]; then
    # Symlink: drop it if it already points at the right place, else replace.
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      echo "ok:    $dest"
      return
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    echo "backup: $dest -> ${dest}${BACKUP_SUFFIX}"
    mv "$dest" "${dest}${BACKUP_SUFFIX}"
  fi
  ln -s "$src" "$dest"
  echo "link:  $dest -> $src"
}

repair_stale_symlinks() {
  # Any of our symlink targets that no longer resolve is a leftover from a
  # moved/renamed clone. Remove it so link_file can recreate it.
  local dest
  for dest in "$@"; do
    if [[ -L "$dest" && ! -e "$dest" ]]; then
      echo "stale: $dest -> $(readlink "$dest")"
      rm "$dest"
    fi
  done
}

echo "==> dotfiles at $DOTFILES_DIR"

if command -v brew >/dev/null 2>&1; then
  echo "==> brew bundle"
  brew bundle --file="$DOTFILES_DIR/Brewfile" || echo "brew bundle had issues — continuing"
else
  echo "brew not found — skipping Brewfile (install https://brew.sh first)"
fi

GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
TMUX_CONFIG="$HOME/.tmux.conf"
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.jsonc"
# codex: a profile layer, so ~/.codex/config.toml (model, marketplaces, plugins,
# per-project trust) is left alone. Selected by `cx` -> codex -p dotfiles.
CODEX_PROFILE="$HOME/.codex/dotfiles.config.toml"
AIDER_CONFIG="$HOME/.aider.conf.yml"
FISH_DIR="$HOME/.config/fish"

repair_stale_symlinks \
  "$GHOSTTY_CONFIG" \
  "$TMUX_CONFIG" \
  "$OPENCODE_CONFIG" \
  "$CODEX_PROFILE" \
  "$AIDER_CONFIG" \
  "$FISH_DIR/config.fish" \
  "$FISH_DIR/conf.d" \
  "$FISH_DIR/functions" \
  "$FISH_DIR/completions"

link_file "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG"
# Starship is managed by stellar (https://stellar.a3chron.dev), not symlinked.
# The old hand-rolled config is kept for reference only, at starship/starship.toml.
link_file "$DOTFILES_DIR/tmux/tmux.conf" "$TMUX_CONFIG"
link_file "$DOTFILES_DIR/opencode/opencode.jsonc" "$OPENCODE_CONFIG"
link_file "$DOTFILES_DIR/codex/dotfiles.config.toml" "$CODEX_PROFILE"
link_file "$DOTFILES_DIR/aider/aider.conf.yml" "$AIDER_CONFIG"

# fish/: link the entry points individually so unrelated files (backups, local
# snippets) in ~/.config/fish survive a re-run.
mkdir -p "$FISH_DIR"
for entry in config.fish conf.d functions completions; do
  if [[ -e "$DOTFILES_DIR/fish/$entry" ]]; then
    link_file "$DOTFILES_DIR/fish/$entry" "$FISH_DIR/$entry"
  fi
done

chmod +x "$DOTFILES_DIR/scripts/"*.sh "$DOTFILES_DIR/git/hooks/pre-commit"

if command -v git >/dev/null 2>&1; then
  # Replace, don't append: re-running the installer would otherwise stack up
  # duplicate include.path entries.
  git config --global --replace-all include.path "$DOTFILES_DIR/git/gitconfig.extra"
  if [[ -r "$DOTFILES_DIR/git/gitconfig.extra" ]]; then
    echo "git include.path -> $DOTFILES_DIR/git/gitconfig.extra"
  fi
fi

# stellar (starship theme manager) + ctp-blue theme
export PATH="$HOME/.local/bin:$PATH"
if ! command -v stellar >/dev/null 2>&1; then
  echo "==> installing stellar"
  curl -fsSL https://raw.githubusercontent.com/a3chron/stellar/main/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"
stellar apply a3chron/ctp-blue
# Write generated completions to the live fish dir, not the repo, so installs
# never leave the working tree dirty.
stellar completion fish >"$FISH_DIR/completions/stellar.fish" 2>/dev/null ||
  echo "warning: could not write stellar completions"
echo "stellar theme -> $(stellar current 2>/dev/null | head -n 5 | tr '\n' ' ')"

cat <<EOF

done. Notes:
- Secrets: use 1Password refs (.env.example). Never commit .env.
- Linked automatically: ghostty, tmux, opencode, fish, and the agent baselines
  codex/dotfiles.config.toml + aider/aider.conf.yml.
- Merge-only templates (not symlinked, so your live settings survive):
      claude/settings.shared.json -> ~/.claude/settings.json
      copilot/settings.shared.json -> ~/.copilot/settings.json
- Per-repo secret hook: cp $DOTFILES_DIR/git/hooks/pre-commit .git/hooks/pre-commit
- Parallel agents: .worktrees/<name> via 'agent-new <name>' (git-ignored, one agent per branch).
Reload Ghostty (Cmd+Shift+,) and open a new tab.
EOF
