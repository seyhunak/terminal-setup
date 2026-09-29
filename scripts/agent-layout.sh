#!/usr/bin/env bash
# agent-layout.sh — persistent tmux session for agentic dev.
# Usage: agent-layout.sh [session-name] [agent-cmd]
# Windows: 1:editor (nvim .)  2:agent (opencode/claude/codex)  3:server (shell)
# Attaches if session exists; safe to re-run.
set -euo pipefail

SESSION="${1:-agent}"
AGENT_CMD="${2:-opencode}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "error: tmux not installed (brew install tmux)" >&2
  exit 1
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$SESSION"
  else
    tmux attach-session -t "$SESSION"
  fi
  exit 0
fi

tmux new-session -d -s "$SESSION" -n "editor" -c "$PWD"
# Only pre-fill the editor if nvim exists; otherwise leave a usable shell.
if command -v nvim >/dev/null 2>&1; then
  tmux send-keys -t "$SESSION:editor" "nvim ." Enter
fi
tmux new-window -t "$SESSION" -n "agent" -c "$PWD"
tmux send-keys -t "$SESSION:agent" "$AGENT_CMD" Enter
tmux new-window -t "$SESSION" -n "server" -c "$PWD"
tmux select-window -t "$SESSION:agent"

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$SESSION"
else
  tmux attach-session -t "$SESSION"
fi
