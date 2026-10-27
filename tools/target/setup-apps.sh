#!/usr/bin/env bash
# One-time database/install steps for target apps that ship without an
# initialised database (DVWA, bWAPP, Mutillidae). Called by lab-boot.sh after
# the containers are up.
#
# Idempotent and self-healing: each app's installer runs ONLY if that app is
# currently showing a database error, so re-running on every boot neither wipes
# a working database nor leaves a broken one.
set -uo pipefail
log() { echo "[setup-apps $(date -u +%FT%TZ)] $*"; }

# Wait until an app's URL responds at all (its container + any bundled DB need
# a moment after first start). Returns 0 once it answers, 1 on timeout.
wait_up() {
  local url=$1
  for _ in $(seq 1 40); do
    if curl -gs -o /dev/null -m 5 "$url"; then return 0; fi
    sleep 3
  done
  return 1
}

# --- DVWA: create/reset the database via setup.php (needs a CSRF user_token) ---
setup_dvwa() {
  local url=http://localhost:8081/login.php
  wait_up "$url" || { log "DVWA not responding, skipping"; return; }
  if ! curl -s -m 8 "$url" | grep -qiE 'Fatal error|Unknown database|Could not connect'; then
    log "DVWA database already OK"; return
  fi
  log "DVWA: initialising database"
  local jar tok
  jar=$(mktemp)
  tok=$(curl -s -c "$jar" http://localhost:8081/setup.php | grep -i user_token | grep -oE '[0-9a-f]{32}' | head -1)
  curl -s -b "$jar" -c "$jar" -X POST http://localhost:8081/setup.php \
    --data-urlencode 'create_db=Create / Reset Database' \
    --data-urlencode "user_token=$tok" -o /dev/null
  rm -f "$jar"
}

# --- bWAPP: install.php?install=yes creates the 'bWAPP' database ---
setup_bwapp() {
  local url=http://localhost:8083/login.php
  wait_up "$url" || { log "bWAPP not responding, skipping"; return; }
  if ! curl -s -m 8 "$url" | grep -qiE 'Unknown database|Connection failed'; then
    log "bWAPP database already OK"; return
  fi
  log "bWAPP: running installer"
  curl -s -m 40 'http://localhost:8083/install.php?install=yes' -o /dev/null
}

# --- Mutillidae: set-up-database.php builds/reset the schema ---
setup_mutillidae() {
  local probe="http://localhost:8084/index.php?page=user-info.php&username=x&password=x&user-info-php-submit-button=View+Account+Details"
  wait_up "http://localhost:8084/" || { log "Mutillidae not responding, skipping"; return; }
  if ! curl -gs -m 8 "$probe" | grep -qiE "doesn't exist|No database selected|Error establishing|Unknown database"; then
    log "Mutillidae database already OK"; return
  fi
  log "Mutillidae: setting up database"
  curl -s -m 40 'http://localhost:8084/set-up-database.php' -o /dev/null
}

# --- VAmPI: GET /createdb creates and populates the SQLite database ---
setup_vampi() {
  wait_up "http://localhost:8085/" || { log "VAmPI not responding, skipping"; return; }
  log "VAmPI: seeding database (/createdb)"
  curl -s -m 20 'http://localhost:8085/createdb' -o /dev/null
}

setup_dvwa
setup_bwapp
setup_mutillidae
setup_vampi
log "app database setup complete"
