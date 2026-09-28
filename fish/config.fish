# ~/.config/fish/config.fish - interactive only
status is-interactive; or return

set -gx PATH /opt/homebrew/bin $PATH
set -gx EDITOR nvim
set -gx BAT_THEME "Catppuccin Mocha"
set -gx FZF_DEFAULT_COMMAND 'fd --hidden --follow --exclude .git'
set -gx EZA_ICONS_AUTO 1

command -q starship; and starship init fish | source
command -q zoxide; and zoxide init fish | source
command -q fzf; and fzf --fish | source

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

set -g fish_greeting ""
fish_vi_key_bindings
