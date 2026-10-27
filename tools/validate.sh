#!/usr/bin/env bash
# validate.sh - end-to-end smoke test for the lab.
#
# Run it ON THE ATTACKER instance (it needs network line-of-sight to the target
# and a real egress posture to test):
#     export TARGET_HOST=10.20.1.x      # or rely on /opt/lab/lab.env
#     /opt/lab/repo/tools/validate.sh
#
# Checks, in order:
#   1. attacker can reach every vulnerable app port on the target
#   2. HexStrike API server is healthy on the attacker (if started)
#   3. egress: in Locked mode an external host must FAIL; in Open it should pass
#
# Exit code is non-zero if any REQUIRED check fails (egress is reported, not
# failed, because the expected result depends on the current mode).
set -uo pipefail

LAB_ENV="${LAB_ENV:-/opt/lab/lab.env}"
# shellcheck source=/dev/null
[ -f "$LAB_ENV" ] && . "$LAB_ENV"

TARGET_HOST="${TARGET_HOST:-}"
HEXSTRIKE_PORT="${HEXSTRIKE_PORT:-8888}"
EXTERNAL_PROBE="${EXTERNAL_PROBE:-https://example.com}"
fail=0

say()  { printf '\n=== %s ===\n' "$*"; }
pass() { printf '  [PASS] %s\n' "$*"; }
bad()  { printf '  [FAIL] %s\n' "$*"; fail=1; }
info() { printf '  [INFO] %s\n' "$*"; }

if [ -z "$TARGET_HOST" ]; then
  echo "ERROR: TARGET_HOST not set and not in $LAB_ENV" >&2
  exit 2
fi

# app label -> host port
PORTS="juice-shop:3000 dvwa:8081 webgoat:8082 bwapp:8083 mutillidae:8084 vampi:8085 vulnerable-flask:8086"

say "1. target app reachability from the attacker ($TARGET_HOST)"
for entry in $PORTS; do
  name="${entry%%:*}"; port="${entry##*:}"
  if curl -fsS -m 10 -o /dev/null "http://${TARGET_HOST}:${port}/" \
     || curl -fsS -m 10 -o /dev/null -k "https://${TARGET_HOST}:${port}/"; then
    pass "$name on :$port responds"
  else
    bad "$name on :$port did NOT respond"
  fi
done

say "2. HexStrike API health (attacker localhost:$HEXSTRIKE_PORT)"
if curl -fsS -m 5 "http://localhost:${HEXSTRIKE_PORT}/health" >/dev/null 2>&1; then
  pass "HexStrike API healthy"
else
  info "HexStrike API not responding - start it with 'hexstrike-start' (not fatal)"
fi

say "3. egress posture (probe: $EXTERNAL_PROBE)"
if curl -fsS -m 8 -o /dev/null "$EXTERNAL_PROBE" 2>/dev/null; then
  info "external egress SUCCEEDED -> you are in OPEN mode (expected during setup)"
  info "switch the stack to AttackerEgressMode=Locked before the attack exercises"
else
  info "external egress BLOCKED -> you are in LOCKED mode (expected during exercises)"
fi

say "summary"
if [ "$fail" -eq 0 ]; then
  echo "  core checks passed."
else
  echo "  one or more REQUIRED checks failed - see [FAIL] lines above."
fi
exit "$fail"
