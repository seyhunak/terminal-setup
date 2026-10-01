# Hands any interactive zsh over to fish so the fish abbrs (oc, cc, cx, al, an)
# always exist. Spliced into ~/.zshrc between markers by install.sh; delete the
# block to keep zsh, or one-shot with DOTFILES_FISH_HANDOFF=off zsh.
[[ -o interactive && -t 0 && -t 1 ]] || return 0
case ${DOTFILES_FISH_HANDOFF:-} in
  1|off|0|no) return 0 ;;
esac
[[ -x /opt/homebrew/bin/fish ]] || return 0
export DOTFILES_FISH_HANDOFF=1
exec /opt/homebrew/bin/fish --login
