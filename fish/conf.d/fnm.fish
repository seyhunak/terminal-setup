# ~/.config/fish/conf.d/fnm.fish — Node via fnm.
# mise is the primary runtime manager (activated in config.fish), so fnm only
# claims the shell when mise is absent. Otherwise `fnm use` still works, it just
# doesn't shim `node` ahead of mise on PATH.
if not command -q mise; and command -q fnm
    fnm env --use-on-cd | source
end