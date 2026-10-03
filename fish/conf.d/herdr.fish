# herdr completions, generated from the binary so they track the installed
# version. Written to the live fish completions dir by install.sh (never into
# the repo, which keeps the working tree clean). Falls back to a direct pipe if
# the file has not been generated yet.
if test -r "$HOME/.config/fish/completions/herdr.fish"
    source "$HOME/.config/fish/completions/herdr.fish"
else if command -q herdr
    herdr completion fish 2>/dev/null | source
end