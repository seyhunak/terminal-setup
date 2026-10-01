# ~/.config/fish/conf.d/atuin.fish — history with search + sync.
# Only the environment here; `atuin init fish | source` lives in config.fish so
# it runs after fish_vi_key_bindings and does not lose the ctrl-r/up bindings.
# Sync is opt-in: run `atuin register` once, credentials via `op` or the prompt.
set -gx ATUIN_CONFIG_DIR "$HOME/.config/atuin"