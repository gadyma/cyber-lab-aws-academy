#!/usr/bin/env bash
# Kasm single-container images execute /dockerstartup/custom_startup.sh (if
# present and executable) as the desktop user during startup. We use it to
# auto-start the HexStrike API server in the background so the desktop is ready
# to use. It must NOT block, so hexstrike-start backgrounds the server itself.
#
# If auto-start ever fails, just open a terminal in the desktop and run
# `hexstrike-start` by hand - the lab does not depend on this hook.
set -euo pipefail
/usr/local/bin/hexstrike-start || true
