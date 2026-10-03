#!/usr/bin/env bash
# agent-duo.sh — leader/worker agent layout in tmux, opened from Ghostty.
#
# Usage: agent-duo.sh [session] [worktree-name] [brief-file]
#
# Layout (one window, three panes):
#
#   ┌──────────────────────┬────────────────────┐
#   │ pane 1  leader       │ pane 2  worker     │
#   │ cline (takes input,  │ cline (executes    │
#   │  plans, dispatches)  │  dispatched tasks) │
#   ├──────────────────────┼────────────────────┤
#   │                      │ pane 3  git        │
#   │                      │ lazygit            │
#   └──────────────────────┴────────────────────┘
#
# The leader talks to the worker through agent-send.sh (see below), so the two
# agents never share a TTY. Attaches if the session already exists; safe to
# re-run. Panes start the same CLI by default (cline); override with
# AGENT_DUO_LEADER_CMD / AGENT_DUO_WORKER_CMD / AGENT_DUO_GIT_CMD.
set -euo pipefail

SESSION="${1:-duo}"
WORKTREE="${2:-}"
BRIEF="${3:-}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

LEADER_CMD="${AGENT_DUO_LEADER_CMD:-cline -i --auto-approve false}"
WORKER_CMD="${AGENT_DUO_WORKER_CMD:-cline -i --auto-approve false}"
GIT_CMD="${AGENT_DUO_GIT_CMD:-lazygit}"

# cline's bare form is a one-shot run that exits as soon as the task is done;
# `-i` opens the interactive TUI that both panes need. --auto-approve defaults to
# true upstream, so it is turned off explicitly to keep this repo's rule of no
# unattended approvals. The worker may still be dispatched to explicitly.

# default session for agent-send.sh, so both scripts agree without arguments
export AGENT_DUO_SESSION="$SESSION"

die() { echo "error: $*" >&2; exit 1; }

command -v tmux >/dev/null 2>&1 || die "tmux not installed (brew install tmux)"

DIR="$PWD"

# Worktree: the worker gets its own branch and directory, so leader and worker
# are never on one branch (the rule the rest of this repo is built around).
# The brief arrives by env var, not a third positional: the worktree argument is
# optional, so a positional brief would slide into the worktree slot whenever the
# caller passes only a session name.
if [[ -n "${AGENT_DUO_BRIEF:-}" ]]; then
  BRIEF="$AGENT_DUO_BRIEF"
fi
if [[ -n "$WORKTREE" ]]; then
  [[ -x "$DOTFILES_DIR/scripts/git-worktree-add.sh" ]] ||
    die "git-worktree-add.sh not found next to this script"
  DIR="$("$DOTFILES_DIR/scripts/git-worktree-add.sh" "$WORKTREE")"
  echo "worktree: $DIR"
fi

brief() {
  cat <<EOF

agent-duo ready — session '$SESSION' in $DIR

  pane 1  leader   $LEADER_CMD    <- start here: type your goal
  pane 2  worker   $WORKER_CMD    <- receives dispatched tasks
  pane 3  git      $GIT_CMD

  from the leader (or any shell in this repo):
    agent-send.sh "add the retry to the fetch path"
    agent-send.sh --file brief.md
    agent-send.sh --capture            # read the worker's output back

  tmux: prefix+1 / prefix+2 / prefix+3 jump to leader / worker / git,
        prefix+z zoom, prefix+d detach (the layout keeps running).
EOF
}

if tmux has-session -t "$SESSION" 2>/dev/null; then
  brief
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$SESSION"
  elif [[ -t 0 ]]; then
    tmux attach-session -t "$SESSION"
  else
    echo "(stdout is not a tty — not attaching)" >&2
  fi
  exit 0
fi

# --- build -----------------------------------------------------------------
# Full terminal width, so the split geometry is computed against real columns.
# Inside tmux the attached client is authoritative; outside, tput is. 200 is the
# fallback for a non-interactive stdout (CI, pipes), where tmux would use 80.
terminal_width() {
  local w=""
  if [[ -n "${TMUX:-}" ]]; then
    w="$(tmux display-message -p '#{client_width}' 2>/dev/null || true)"
  fi
  [[ -z "$w" ]] && w="$(tput cols 2>/dev/null || true)"
  [[ "$w" =~ ^[0-9]+$ ]] || w=200
  printf '%s' "$w"
}

WINDOW_COLS="$(terminal_width)"
# Keep both columns usable: below ~100 columns the split is not worth having.
[[ "$WINDOW_COLS" -lt 100 ]] && WINDOW_COLS=100

# The leader gets ~60% of the window; the worker/git column gets the rest.
LEADER_COLS="$(( WINDOW_COLS * 60 / 100 ))"
(( LEADER_COLS < 60 )) && LEADER_COLS=60

# No client attached yet: create the session at the real terminal size so the
# split geometry is computed against real columns, not the 80x24 default.
CREATE_ARGS=()
if ! tmux list-clients -t "$SESSION" 2>/dev/null | grep -q .; then
  CREATE_ARGS=(-x "$WINDOW_COLS" -y 50)
fi

# Window 1 starts as the leader; the two right panes are created from it and
# the layout pass gives the leader the wide column.
tmux new-session -d -s "$SESSION" -n "duo" -c "$DIR" "${CREATE_ARGS[@]}"
# main-pane-width keeps the leader's share when tmux re-lays-out the window
# (e.g. on a terminal resize); the explicit resize below sets it right now.
tmux set-option -t "$SESSION" -w main-pane-width "$LEADER_COLS" 2>/dev/null || true
tmux set-option -p -t "$SESSION:duo.1" @agent_role leader
tmux send-keys -t "$SESSION:duo.1" "$LEADER_CMD" Enter

tmux split-window -h -t "$SESSION:duo.1" -c "$DIR"
tmux split-window -v -t "$SESSION:duo.2" -c "$DIR"
tmux select-layout -t "$SESSION:duo" main-vertical
tmux resize-pane -t "$SESSION:duo.1" -x "$LEADER_COLS" 2>/dev/null || true

tmux set-option -p -t "$SESSION:duo.2" @agent_role worker
tmux send-keys -t "$SESSION:duo.2" "$WORKER_CMD" Enter

tmux set-option -p -t "$SESSION:duo.3" @agent_role git
# lazygit is a git TUI: only start it inside a worktree, or it exits instantly.
if [[ "$DIR" == *.git ]] || git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  tmux send-keys -t "$SESSION:duo.3" "$GIT_CMD" Enter
else
  tmux send-keys -t "$SESSION:duo.3" "echo 'not a git repo — cd into one and re-run'" Enter
fi

# Brief: pasted as the leader's opening prompt when a file is given, so the
# leader starts already knowing the dispatch protocol.
if [[ -n "$BRIEF" ]]; then
  [[ -r "$BRIEF" ]] || die "brief file not readable: $BRIEF"
  tmux load-buffer -b agent-duo-brief "$BRIEF"
  tmux paste-buffer -b agent-duo-brief -d -t "$SESSION:duo.1"
  sleep 0.4
  tmux send-keys -t "$SESSION:duo.1" Enter
  tmux delete-buffer -b agent-duo-brief 2>/dev/null || true
fi

tmux select-pane -t "$SESSION:duo.1"
brief

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$SESSION"
elif [[ -t 0 ]]; then
  tmux attach-session -t "$SESSION"
else
  echo "(stdout is not a tty — session created, not attaching)" >&2
fi