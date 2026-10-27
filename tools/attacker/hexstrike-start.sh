#!/usr/bin/env bash
# Start the HexStrike AI API server (port 8888) inside the Kali desktop.
# Works whether HexStrike came from the Kali apt package or the upstream repo.
#
# The AI side (an MCP client wired to your LLM / Bedrock endpoint) connects to
# this server; see lessons/ and docs/safety.md for the egress rules that apply.
set -euo pipefail

PORT="${HEXSTRIKE_PORT:-8888}"
LOG="${HEXSTRIKE_LOG:-$HOME/hexstrike-server.log}"

start_repo() {
  local d=/opt/hexstrike-ai
  echo "Starting HexStrike (upstream repo) on :$PORT"
  cd "$d"
  nohup "$d/venv/bin/python" hexstrike_server.py --port "$PORT" >>"$LOG" 2>&1 &
}

start_pkg() {
  echo "Starting HexStrike (Kali package) on :$PORT"
  nohup hexstrike-ai --port "$PORT" >>"$LOG" 2>&1 \
    || nohup hexstrike_server --port "$PORT" >>"$LOG" 2>&1 &
}

if command -v hexstrike-ai >/dev/null 2>&1 || command -v hexstrike_server >/dev/null 2>&1; then
  start_pkg
elif [ -x /opt/hexstrike-ai/venv/bin/python ]; then
  start_repo
else
  echo "ERROR: HexStrike is not installed in this image." >&2
  exit 1
fi

sleep 3
if curl -fsS "http://localhost:${PORT}/health" >/dev/null 2>&1; then
  echo "HexStrike API healthy on http://localhost:${PORT}"
else
  echo "HexStrike started; /health not confirmed yet. Tail the log: $LOG"
fi

cat <<EOF

Next: connect an MCP client to this server, e.g.
  hexstrike_mcp.py --server http://localhost:${PORT}
Wire that client's model to your approved LLM endpoint (LLM_ENDPOINT in
/opt/lab/lab.env). Keep attacks inside the lab VPC only - see docs/safety.md.
EOF
