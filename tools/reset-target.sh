#!/usr/bin/env bash
# reset-target.sh - restore the target to a clean state between lessons.
# Tears down the vulnerable-app containers AND their volumes (wiping any state a
# previous exercise left behind), then brings them back up and re-plants flags.
#
# Run ON the target instance:  sudo /opt/lab/repo/tools/reset-target.sh
set -euo pipefail

LAB_ENV="${LAB_ENV:-/opt/lab/lab.env}"
# shellcheck source=/dev/null
[ -f "$LAB_ENV" ] && . "$LAB_ENV"
REPO_DIR="${REPO_DIR:-/opt/lab/repo}"

cd "$REPO_DIR/tools/target"
echo "[reset] stopping and removing containers + volumes..."
docker compose down -v --remove-orphans

echo "[reset] pulling fresh images (best effort)..."
docker compose pull --quiet || echo "[reset] pull skipped (offline); using cached images"

echo "[reset] starting clean stack..."
docker compose up -d

if [ "${ENABLE_FLAGS:-false}" = "true" ]; then
  echo "[reset] re-planting per-student flags..."
  "$REPO_DIR/scoreboard/plant-flags.sh"
fi

echo "[reset] done. target is clean."
