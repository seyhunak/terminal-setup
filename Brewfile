# Brewfile — agentic terminal env (macOS). Install: brew bundle --file=~/dotfiles/Brewfile
brew "fish"
brew "starship"
brew "tmux"
brew "neovim"
brew "git"
brew "git-lfs"
brew "gh"
brew "delta"
brew "direnv"
brew "mise"
brew "asdf"
# NOTE: no fish-autosuggestions / fish-syntax-highlighting here. fish >= 4.0
# ships both natively (fish_color_autosuggestion, the fish_color_* set), so the
# third-party plugins are redundant on this install. See fish/config.fish.
brew "eza"
brew "zoxide"
brew "fzf"
brew "fd"
brew "bat"
brew "ripgrep"
brew "jq"
brew "lazygit"
brew "yazi"
brew "uv"
# Shell history with search + cross-machine sync. Activated in
# fish/conf.d/atuin.fish; needs `atuin register` once for sync.
brew "atuin"
# Runtime managers. mise is the one that is actually activated (config.fish);
# fnm and pyenv are installed for projects that pin .node-version / .python-version
# outside mise, and are only activated when mise is absent — see conf.d.
brew "fnm"
brew "pyenv"
# Corrections and process inspection
brew "thefuck"
brew "htop"
cask "ghostty"
cask "1password-cli"
# Nerd Font. Installed by the cask; if `brew bundle` cannot satisfy it (network
# or cask unavailable), drop the JetBrainsMonoNerdFont-*.ttf files from
# https://github.com/ryanoasis/nerd-fonts/releases into ~/Library/Fonts.
cask "font-jetbrains-mono-nerd-font"
