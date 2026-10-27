#!/usr/bin/env bash
# generate-flags.sh - print every (student, app, flag) for a roster as CSV.
#
#   FLAG_SECRET='class-secret' ./generate-flags.sh roster.txt > flags.csv
#
# roster.txt: one StudentId per line (blank lines and #comments ignored).
# Output columns: student_id,app,flag
set -euo pipefail

ROSTER="${1:-}"
FLAG_SECRET="${FLAG_SECRET:-change-me-flag-secret}"
APPS="juiceshop dvwa webgoat bwapp mutillidae vampi flask"

if [ -z "$ROSTER" ] || [ ! -f "$ROSTER" ]; then
  echo "usage: FLAG_SECRET=... $0 <roster.txt>" >&2
  exit 2
fi

flag_for() {
  local sid="$1" app="$2" digest
  digest=$(printf '%s' "${sid}:${app}" \
    | openssl dgst -sha256 -hmac "$FLAG_SECRET" -r \
    | cut -d' ' -f1)
  printf 'FLAG{%s_%s}' "$app" "${digest:0:16}"
}

echo "student_id,app,flag"
while IFS= read -r line || [ -n "$line" ]; do
  sid="$(printf '%s' "$line" | tr -d '[:space:]')"
  case "$sid" in ""|\#*) continue ;; esac
  for app in $APPS; do
    printf '%s,%s,%s\n' "$sid" "$app" "$(flag_for "$sid" "$app")"
  done
done < "$ROSTER"
