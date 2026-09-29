# agent-new — spin up an isolated worktree + tmux window for a parallel agent.
# Usage: agent-new my-feature
# Creates .worktrees/my-feature (new branch), then opens a tmux window there.
function agent-new --description 'New agent worktree + tmux window'
    if test (count $argv) -lt 1
        echo "usage: agent-new <name> [base-branch]" >&2
        return 1
    end
    set -l name $argv[1]
    # Base-branch resolution (origin/<base> then HEAD) lives in the script; only
    # pass a base through when the caller actually gave one.
    set -l wt_args $name
    if test (count $argv) -ge 2
        set -a wt_args $argv[2]
    end
    if not command -q git-worktree-add.sh
        echo "agent-new: git-worktree-add.sh not on PATH (run ./install.sh)" >&2
        return 1
    end
    set -l wt_path (git-worktree-add.sh $wt_args)
    or return 1
    echo "worktree: $wt_path"
    if test -n "$TMUX"
        tmux new-window -c "$wt_path" -n "agent:$name"
    else if command -q tmux
        tmux new-window -c "$wt_path" -n "agent:$name" 2>/dev/null; or echo "outside tmux — cd $wt_path to start agent"
    else
        echo "cd $wt_path to start agent"
    end
end
