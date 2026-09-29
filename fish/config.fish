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
# agents (safe defaults — add --yolo/--dangerously-skip-permissions explicitly per run)
abbr -a oc 'opencode'
abbr -a ocr 'opencode --continue'
abbr -a cc 'claude'
abbr -a ccr 'claude --continue'
abbr -a cx 'codex'
abbr -a cr 'crush'
abbr -a co 'copilot'
# 1Password: inject secrets per-command, e.g. `opr --env-file=.env -- opencode`
abbr -a opr 'op run --'
# agentic workflows
abbr -a al 'agent-layout.sh'
abbr -a wt 'git-worktree-add.sh'
abbr -a an 'agent-new'

set -g fish_greeting ""
fish_vi_key_bindings
