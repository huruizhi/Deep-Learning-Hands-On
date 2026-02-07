#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PY="$ROOT_DIR/.venv/bin/python"
JUPYTER_BIN="$ROOT_DIR/.venv/bin/jupyter"
LOG_FILE="/tmp/dl-handson-jupyter.log"
PID_FILE="/tmp/dl-handson-jupyter.pid"
IP="127.0.0.1"
PORT="8889"

if [[ ! -x "$VENV_PY" || ! -x "$JUPYTER_BIN" ]]; then
  echo "Virtual environment not found. Please create it first:"
  echo "  cd $ROOT_DIR && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
  exit 1
fi

if [[ -f "$PID_FILE" ]]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${OLD_PID:-}" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "Jupyter is already running (PID: $OLD_PID)."
    echo "Use ./stop_jupyter.sh first if you want to restart."
    exit 0
  fi
fi

nohup "$JUPYTER_BIN" lab --no-browser --ip "$IP" --port "$PORT" >"$LOG_FILE" 2>&1 &
NEW_PID="$!"
echo "$NEW_PID" >"$PID_FILE"

echo "Starting JupyterLab (PID: $NEW_PID)..."
for _ in {1..20}; do
  if grep -q "http://$IP:$PORT/lab?token=" "$LOG_FILE"; then
    break
  fi
  sleep 1
done

URL="$(grep -Eo "http://$IP:$PORT/lab\\?token=[^ ]+" "$LOG_FILE" | tail -n 1 || true)"
if [[ -n "$URL" ]]; then
  echo "JupyterLab is ready:"
  echo "  $URL"
else
  echo "Jupyter started, but URL not found yet. Check:"
  echo "  tail -n 100 $LOG_FILE"
fi
