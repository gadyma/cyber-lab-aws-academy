#!/usr/bin/env bash
# plant-flags.sh - drop a per-student CTF flag into each target container.
#
# The flag is derived deterministically so the instructor can recompute and
# verify it WITHOUT any cross-account access to the student's lab:
#
#     flag = FLAG{ <app> _ HMAC-SHA256(FlagSecret, "StudentId:app")[:16] }
#
# Same FlagSecret across all students -> the instructor recomputes any student's
# flag from (StudentId, app) alone. See scoreboard/README.md for the convention
# and the verification helper.
#
# Run ON the target (lab-boot.sh calls it when ENABLE_FLAGS=true):
#     sudo /opt/lab/repo/scoreboard/plant-flags.sh
set -euo pipefail

LAB_ENV="${LAB_ENV:-/opt/lab/lab.env}"
# shellcheck source=/dev/null
[ -f "$LAB_ENV" ] && . "$LAB_ENV"

STUDENT_ID="${STUDENT_ID:-student-000}"
FLAG_SECRET="${FLAG_SECRET:-change-me-flag-secret}"
FLAG_PATH="${FLAG_PATH:-/flag.txt}"

# service name in docker-compose  ->  label used in the flag
declare -A APPS=(
  [juice-shop]=juiceshop
  [dvwa]=dvwa
  [webgoat]=webgoat
  [bwapp]=bwapp
  [mutillidae]=mutillidae
  [vampi]=vampi
  [vulnerable-flask]=flask
)

derive_flag() {
  # $1 = app label
  local app="$1" digest
  digest=$(printf '%s' "${STUDENT_ID}:${app}" \
    | openssl dgst -sha256 -hmac "$FLAG_SECRET" -r \
    | cut -d' ' -f1)
  printf 'FLAG{%s_%s}' "$app" "${digest:0:16}"
}

for svc in "${!APPS[@]}"; do
  label="${APPS[$svc]}"
  flag="$(derive_flag "$label")"
  cid="$(docker compose -f /opt/lab/repo/tools/target/docker-compose.yml ps -q "$svc" 2>/dev/null || true)"
  if [ -z "$cid" ]; then
    echo "[flags] WARN: container for '$svc' not running yet; skipping"
    continue
  fi
  # Write the flag into the container at FLAG_PATH. Use a shell inside the
  # container so it works regardless of the image's tooling.
  if docker exec "$cid" sh -c "printf '%s\n' '$flag' > '$FLAG_PATH' 2>/dev/null"; then
    echo "[flags] planted $label flag in $svc at $FLAG_PATH"
  else
    echo "[flags] WARN: could not write flag into $svc (read-only fs?)"
  fi
done

echo "[flags] done for student '$STUDENT_ID'."
