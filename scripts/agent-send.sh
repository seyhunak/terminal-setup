#!/usr/bin/env bash
# agent-send.sh — the leader -> worker channel for the agent-duo layout.
#
# Usage:
#   agent-send.sh "task text"          paste text into the worker pane, then Enter
#   agent-send.sh --file brief.md      same, from a file (multiline safe)
#   agent-send.sh --capture            print the worker's visible output and exit
#   agent-send.sh --capture -S -200    print 200 lines of scrollback
#   agent-send.sh --target leader      talk to the leader pane instead
#   agent-send.sh --no-enter           paste only, for multi-part instructions
#
# Paste goes through a tmux buffer rather than send-keys so multiline text and
# characters tmux would treat as keys (';', 'C-c', ...) stay literal.
set -euo pipefail

SESSION="${AGENT_DUO_SESSION:-duo}"
WINDOW="duo"
TARGET="worker"
CAPTURE=0
ENTER=1
FILE=""
SCROLL=""
TEXT=""

die() { echo "error: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)   TARGET="${2:?--target needs worker|leader}"; shift 2 ;;
    --session)  SESSION="${2:?--session needs a name}"; shift 2 ;;
    --file)     FILE="${2:?--file needs a path}"; shift 2 ;;
    --capture)  CAPTURE=1; shift ;;
    --no-enter) ENTER=0; shift ;;
    -S)         SCROLL="${2:?-S needs a line count}"; shift 2 ;;
    --help|-h)  sed -n '2,15p' "$0" | sed 's/^# \?//'; exit 0 ;;
    --)         shift; TEXT="$*"; break ;;
    -*)         die "unknown flag: $1" ;;
    *)
      [[ -n "$TEXT" ]] && die "one task only — quote it as a single argument"
      TEXT="$1"; shift ;;
  esac
done

command -v tmux >/dev/null 2>&1 || die "tmux not installed"
tmux has-session -t "$SESSION" 2>/dev/null || die "no tmux session '$SESSION' (run agent-duo.sh first)"

# Resolve by the @agent_role user option, not pane index and not pane_title:
# fish's title integration rewrites pane_title, so titles are unusable as a
# stable key. The user option is set by agent-duo.sh and shells never touch it.
PANE="$(tmux list-panes -t "$SESSION:$WINDOW" -F '#{pane_id} #{@agent_role}' 2>/dev/null |
        awk -v want="$TARGET" '$2 == want { print $1; exit }')"
if [[ -z "$PANE" ]]; then
  die "no pane tagged '$TARGET' in $SESSION:$WINDOW (run agent-duo.sh to create the layout)"
fi

if [[ "$CAPTURE" -eq 1 ]]; then
  if [[ -n "$SCROLL" ]]; then
    tmux capture-pane -p -S "$SCROLL" -t "$PANE"
  else
    tmux capture-pane -p -t "$PANE"
  fi
  exit 0
fi

if [[ -n "$FILE" ]]; then
  [[ -r "$FILE" ]] || die "brief file not readable: $FILE"
  tmux load-buffer -b agent-send "$FILE"
elif [[ -n "$TEXT" ]]; then
  printf '%s' "$TEXT" | tr '\n' ' ' | tmux load-buffer -b agent-send -
else
  die "nothing to send — pass text, --file, or --capture"
fi

tmux paste-buffer -b agent-send -d -t "$PANE"
tmux delete-buffer -b agent-send 2>/dev/null || true

if [[ "$ENTER" -eq 1 ]]; then
  sleep 0.4   # let the TUI paint before the Enter lands
  tmux send-keys -t "$PANE" Enter
fi