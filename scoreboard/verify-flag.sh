#!/usr/bin/env bash
# verify-flag.sh - recompute the expected flag for one student+app.
# Must match the derivation in plant-flags.sh exactly.
#
#   FLAG_SECRET='class-secret' ./verify-flag.sh <StudentId> <app>
#
# <app> is one of: juiceshop dvwa webgoat bwapp mutillidae vampi flask
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: FLAG_SECRET=... $0 <StudentId> <app>" >&2
  echo "  app: juiceshop|dvwa|webgoat|bwapp|mutillidae|vampi|flask" >&2
  exit 2
fi

STUDENT_ID="$1"
APP="$2"
FLAG_SECRET="${FLAG_SECRET:-change-me-flag-secret}"

if [ "$FLAG_SECRET" = "change-me-flag-secret" ]; then
  echo "WARN: using the default FLAG_SECRET - set FLAG_SECRET to your class secret" >&2
fi

digest=$(printf '%s' "${STUDENT_ID}:${APP}" \
  | openssl dgst -sha256 -hmac "$FLAG_SECRET" -r \
  | cut -d' ' -f1)

printf 'FLAG{%s_%s}\n' "$APP" "${digest:0:16}"
