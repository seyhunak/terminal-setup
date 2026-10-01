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
  # Any of our symlink targets that no longer resolves is a leftover from a
  # moved/renamed clone. Remove it so link_file can recreate it.
  local dest
  for dest in "$@"; do
    if [[ -L "$dest" && ! -e "$dest" ]]; then
      echo "stale: $dest -> $(readlink "$dest")"
      rm "$dest"
    fi
  done
}

# The user's ~/.zshrc is theirs: it carries tool installers and PATH entries we
# know nothing about. So instead of symlinking over it, splice a marked block in
# at the end. Re-running replaces the block in place, never stacks copies.
MARKER_BEGIN="# >>> dotfiles fish handoff >>>"
MARKER_END="# <<< dotfiles fish handoff <<<"

splice_fish_handoff() {
  local src="$1" dest="$2" tmp
  [[ -r "$src" ]] || {
    echo "skip: fish handoff (no $src)"
    return 0
  }
  tmp="$(mktemp)"
  if [[ -e "$dest" ]]; then
    # Drop any previously installed block (markers included), then trim the
    # blank lines it leaves behind so re-runs are byte-stable.
    awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
      $0 == b { skip = 1; next }
      $0 == e { skip = 0; next }
      skip { next }
      { buf[++n] = $0 }
      END {
        while (n > 0 && buf[n] ~ /^[[:space:]]*$/) n--
        for (i = 1; i <= n; i++) print buf[i]
      }
    ' "$dest" >"$tmp"
  fi
  {
    # The user's own lines first, then the handoff block last: the block execs
    # fish, so anything after it would be unreachable.
    [[ -s "$tmp" ]] && cat "$tmp"
    printf '%s\n' "$MARKER_BEGIN"
    cat "$src"
    printf '%s\n' "$MARKER_END"
  } >"$tmp.new"

  if [[ -e "$dest" ]] && cmp -s "$tmp.new" "$dest"; then
    echo "ok:    $dest (fish handoff)"
  else
    [[ -e "$dest" ]] && {
      echo "backup: $dest -> ${dest}${BACKUP_SUFFIX}"
      cp -p "$dest" "${dest}${BACKUP_SUFFIX}"
    }
    mv "$tmp.new" "$dest"
    echo "patch: $dest (+ fish handoff: exec fish)"
  fi
  rm -f "$tmp" "$tmp.new"
}

# fish is absent from /etc/shells on a stock macOS, so `chsh -s fish` is refused
# until it is listed there. Report the gap instead of guessing; changing the
# login shell needs a password, so the user runs it.
report_login_shell() {
  local fish_bin="/opt/homebrew/bin/fish" current
  current="$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')"
  [[ -n "$current" ]] || return 0
  if [[ "$current" == "$fish_bin" ]]; then
    echo "login shell: $current"
    return 0
  fi
  echo "login shell: $current (not fish — Ghostty/tmux override it, other apps won't)"
  grep -qxF "$fish_bin" /etc/shells 2>/dev/null ||
    echo "  missing from /etc/shells: sudo sh -c 'echo $fish_bin >> /etc/shells'"
  echo "  to make fish the default everywhere: chsh -s $fish_bin"
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
ZSHRC="$HOME/.zshrc"

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

# zsh: the macOS login shell is often still /bin/zsh, and anything that does not
# go through Ghostty (Terminal.app, VS Code, ssh, a hand-typed `zsh`) starts
# there — without the fish abbrs. Hand off to fish from ~/.zshrc instead of
# taking that file over.
splice_fish_handoff "$DOTFILES_DIR/zsh/zshrc-fish-handoff.zsh" "$ZSHRC"

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

report_login_shell

cat <<EOF

done. Notes:
- Secrets: use 1Password refs (.env.example). Never commit .env.
- Linked automatically: ghostty, tmux, opencode, fish, and the agent baselines
  codex/dotfiles.config.toml + aider/aider.conf.yml.
- Patched in place (backed up): ~/.zshrc gets a marked block that hands
  interactive zsh over to fish, so oc/cc/cx/al/an exist in every terminal.
  Delete the block to opt out, or one-shot with DOTFILES_FISH_HANDOFF=off zsh.
- Merge-only templates (not symlinked, so your live settings survive):
      claude/settings.shared.json -> ~/.claude/settings.json
      copilot/settings.shared.json -> ~/.copilot/settings.json
- Per-repo secret hook: cp $DOTFILES_DIR/git/hooks/pre-commit .git/hooks/pre-commit
- Parallel agents: .worktrees/<name> via 'agent-new <name>' (git-ignored, one agent per branch).
Open a new terminal (or run 'exec fish'); the current zsh session keeps its old config.
EOF
