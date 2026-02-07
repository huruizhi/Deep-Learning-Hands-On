#!/usr/bin/env bash
set -euo pipefail

PID_FILE="/tmp/dl-handson-jupyter.pid"
PORT="8889"

stopped=0

if [[ -f "$PID_FILE" ]]; then
  PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${PID:-}" ]] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" || true
    sleep 1
    if kill -0 "$PID" 2>/dev/null; then
      kill -9 "$PID" || true
    fi
    stopped=1
    echo "Stopped Jupyter PID: $PID"
  fi
  rm -f "$PID_FILE"
fi

PORT_PIDS="$(lsof -tiTCP:"$PORT" -sTCP:LISTEN 2>/dev/null || true)"
if [[ -n "${PORT_PIDS:-}" ]]; then
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    kill "$p" || true
    stopped=1
    echo "Stopped process on port $PORT: $p"
  done <<<"$PORT_PIDS"
fi

if [[ "$stopped" -eq 0 ]]; then
  echo "No running Jupyter process found."
fi
