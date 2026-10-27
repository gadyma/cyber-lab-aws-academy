#!/usr/bin/env bash
# lab-boot.sh - idempotent lab startup, run by systemd on every boot.
#
# Learner Lab STOPS instances on session timeout, so this must be safe to run
# any number of times. It reads the role from /opt/lab/lab.env (also passed by
# the systemd unit as an EnvironmentFile) and brings up the right stack.
#
# Target  : docker compose of the vulnerable apps, then (optional) plant flags.
# Attacker: build the Kali web-desktop image (cached after first run), bring it
#           up, and make sure HexStrike AI is available inside it.
set -euo pipefail

LAB_ENV="${LAB_ENV:-/opt/lab/lab.env}"
# shellcheck source=/dev/null
[ -f "$LAB_ENV" ] && . "$LAB_ENV"

REPO_DIR="${REPO_DIR:-/opt/lab/repo}"
LAB_ROLE="${LAB_ROLE:-unknown}"
log() { echo "[lab-boot $(date -u +%FT%TZ)] $*"; }

wait_for_docker() {
  for _ in $(seq 1 30); do
    if docker info >/dev/null 2>&1; then return 0; fi
    sleep 2
  done
  log "ERROR: docker did not become ready"; return 1
}

boot_target() {
  log "role=target: starting vulnerable-app stack"
  cd "$REPO_DIR/tools/target"
  # --ignore-buildable: don't try to pull services we build locally (flask).
  docker compose pull --ignore-buildable --quiet || log "WARN: pull incomplete, continuing"
  # Bring everything up; if one service can't be obtained, start the rest
  # individually so a single bad image never sinks the whole stack.
  if ! docker compose up -d --build; then
    log "WARN: 'compose up' failed; starting services individually"
    for svc in $(docker compose config --services); do
      docker compose up -d --build "$svc" || log "WARN: service '$svc' failed to start"
    done
  fi
  # Initialise databases for apps that ship without one (DVWA/bWAPP/Mutillidae).
  log "initialising app databases"
  "$REPO_DIR/tools/target/setup-apps.sh" || log "WARN: app DB setup had issues"
  if [ "${ENABLE_FLAGS:-false}" = "true" ]; then
    log "planting per-student flags"
    "$REPO_DIR/scoreboard/plant-flags.sh" || log "WARN: flag planting failed"
  fi
  log "target up. apps: 3000 juice | 8081 dvwa | 8082 webgoat | 8083 bwapp | 8084 mutillidae | 8085 vampi | 8086 flask"
}

boot_attacker() {
  log "role=attacker: building/starting Kali web desktop"
  cd "$REPO_DIR/tools/attacker"
  # The compose file reads these from the environment (with its own defaults).
  # Build is cached after the first boot, so this stays cheap and idempotent.
  export BASE_IMAGE="${KALI_IMAGE:-kasmweb/kali-rolling-desktop:1.16.0}"
  export KALI_TOOLSET="${KALI_TOOLSET:-kali-tools-top10}"
  export VNC_PW="${KASM_PASSWORD:-ChangeMe-LabPassw0rd!}"
  docker compose build || log "WARN: build failed; will try to run any existing image"
  docker compose up -d
  log "attacker up. web desktop on :6901 (user kasm_user)."
  log "target reachable at TARGET_HOST=${TARGET_HOST:-<unset>}"
  log "start HexStrike inside the desktop terminal with: hexstrike-start"
}

main() {
  wait_for_docker
  case "$LAB_ROLE" in
    target)   boot_target ;;
    attacker) boot_attacker ;;
    *) log "ERROR: LAB_ROLE unset or unknown ('$LAB_ROLE'). Set it in $LAB_ENV"; exit 1 ;;
  esac
}

main "$@"
