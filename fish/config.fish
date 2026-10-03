# ~/.config/fish/config.fish - interactive only
status is-interactive; or return

set -gx PATH /opt/homebrew/bin $PATH
fish_add_path -g $HOME/.local/bin
set -gx EDITOR nvim
set -gx BAT_THEME "Catppuccin Mocha"
set -gx FZF_DEFAULT_COMMAND 'fd --hidden --follow --exclude .git'
set -gx EZA_ICONS_AUTO 1
# Agentic env: prefer 1Password `op run` for secrets, never export tokens
set -gx OPENCODE_AUTO_SHARE false

# Repo root, resolved from this file's own (symlinked) location so the setup
# works no matter where the repo is cloned. Falls back to ~/dotfiles.
set -g __dotfiles_config (status filename)
if command -q realpath
    set -g __dotfiles_config (realpath $__dotfiles_config 2>/dev/null; or echo $__dotfiles_config)
end
set -g __dotfiles_dir (realpath (dirname $__dotfiles_config)/.. 2>/dev/null; or echo $HOME/dotfiles)
set -e __dotfiles_config

if test -d "$__dotfiles_dir/scripts"
    fish_add_path -g $__dotfiles_dir/scripts
else
    echo "fish: dotfiles repo not found at $__dotfiles_dir (scripts not on PATH)" >&2
end

# Autosuggestions (ghost text, right-arrow to accept) and syntax highlighting are
# built into fish >= 4.0 — no plugin needed. Tuned here instead:
#   fish_color_autosuggestion  the ghost text colour
#   fish_color_valid_path      an argument that exists on disk
# Theme the pair to Catppuccin Mocha so they match starship + Ghostty.
set -g fish_color_autosuggestion "#6c7086"  # overlay0, dimmed
set -g fish_color_valid_path "#a6e3a1"     # green

command -q starship; and starship init fish | source
command -q zoxide; and zoxide init fish | source
command -q fzf; and fzf --fish | source
command -q mise; and mise activate fish | source
command -q direnv; and direnv hook fish | source
test -f /opt/homebrew/opt/asdf/libexec/asdf.fish; and source /opt/homebrew/opt/asdf/libexec/asdf.fish

# abbr > alias in fish
abbr -a ls 'eza -lh --group-directories-first --icons=auto'
abbr -a ll 'eza -lah --git --icons=auto'
abbr -a g lazygit
abbr -a gg 'git status -sb'
abbr -a gc 'git commit -m'
abbr -a gp 'git push'
abbr -a v nvim
abbr -a y yazi
abbr -a z zoxide
abbr -a proc htop
# thefuck has no fish integration (3.32 only emits bash/zsh/tcsh glue), so `tf` is
# a plain call: `tf <wrong command>` prints the corrected line. No key binding.
abbr -a tf thefuck
# Agent CLIs. abbr_if registers the shortcut only when the binary exists, so a
# clone on a machine without e.g. aider doesn't collect dead abbrs.
# Safe defaults throughout: no --yolo, no --dangerously-bypass-approvals.
# codex runs the `dotfiles` profile (sandbox workspace-write, on-request approval).
function abbr_if --description 'abbr $argv[1] -> $argv[2..] if the command exists'
    set -l key $argv[1]
    set -e argv[1]
    if command -q $argv[1]
        abbr -a $key $argv
    end
end

abbr_if oc  opencode
abbr_if ocr opencode --continue
abbr_if cc  claude
abbr_if ccr claude --continue
abbr_if cx  codex -p dotfiles
abbr_if cxr codex -p dotfiles resume --last
abbr_if cr  crush
abbr_if co  copilot
abbr_if cn  cline
abbr_if ad  aider
abbr_if gem gemini
# 1Password: inject secrets per-command, e.g. `opr --env-file=.env -- opencode`
abbr -a opr 'op run --'
# agentic workflows
abbr -a al 'agent-layout.sh'
abbr -a duo 'agent-duo'
abbr -a ax 'agent-send.sh'
abbr -a wt 'git-worktree-add.sh'
abbr -a an 'agent-new'

set -g fish_greeting ""
fish_vi_key_bindings

# atuin replaces fish's own history and owns the ctrl-r binding, so it has to be
# initialised after fish_vi_key_bindings or vi keys overwrite it. Env lives in
# conf.d/atuin.fish. Sync is opt-in: `atuin register`.
command -q atuin; and atuin init fish | source
