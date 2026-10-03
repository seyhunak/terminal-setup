# agent-duo — leader/worker layout (left leader, right worker, right lazygit).
# Usage: agent-duo [worktree-name]
# Defaults the brief so the leader pane starts with its dispatch protocol.
function agent-duo --description 'Leader/worker agent layout in tmux'
    # config.fish sets __dotfiles_dir, but this function must also work when
    # config.fish has not been sourced (fish -c, scripts). Walk up from this
    # file until scripts/agent-duo.sh appears: the function is autoloaded from
    # ~/.config/fish/functions, which is a symlink to the repo but not inside it.
    set -l dir $__dotfiles_dir
    if test -z "$dir" -o ! -x "$dir/scripts/agent-duo.sh"
        # realpath, not the raw path: ~/.config/fish/functions is a symlink to
        # the repo, so the repo is not an ancestor of the autoloaded path.
        set -l self (status --current-filename)
        set -l resolved (realpath $self 2>/dev/null)
        test -z "$resolved"; and set resolved $self
        set dir (dirname $resolved)
        # The file sits in <repo>/fish/functions, so two levels up is the root.
        set dir (dirname (dirname $dir))
    end
    set -l script "$dir/scripts/agent-duo.sh"
    if not test -x "$script"
        echo "agent-duo: $script not found (run ./install.sh)" >&2
        return 1
    end
    set -l brief "$dir/agents/leader-brief.md"
    # agent-duo.sh takes [session] [worktree]; the brief rides in an env var so
    # an omitted worktree cannot shift it into the worktree slot.
    set -l args duo
    if test (count $argv) -ge 1
        set -a args $argv[1]
    end
    if test -r "$brief"
        env AGENT_DUO_BRIEF="$brief" command "$script" $args
    else
        command "$script" $args
    end
end