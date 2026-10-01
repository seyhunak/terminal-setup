# ~/.config/fish/conf.d/pyenv.fish — Python via pyenv.
# mise and uv are the primary path (see config.fish / conf.d/uv.env.fish). pyenv
# shims would shadow mise's, so only initialise it when mise is absent — e.g. a
# project pinned with a .python-version on a machine without mise.
if not command -q mise; and command -q pyenv
    set -gx PYENV_ROOT "$HOME/.pyenv"
    pyenv init - | source
end