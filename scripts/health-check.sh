#!/usr/bin/env bash
# Daily health check for the 10-tool free workflow.
# Required check: Cloady hello-world service (must be up).
# Optional checks (warn only, never fail the job): Orca /v1/models and
# Supabase project URL -- both are expected to be down/unreachable at times
# (Kaggle sessions stop after ~40 min idle; Supabase URL is not a web page).
set -u
LOG="health-check.log"
: > "$LOG"

check() {
  local name="$1" url="$2" required="${3:-false}"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$url" || echo "000")
  local line="$(date -u +%FT%TZ) $name $url -> HTTP $code"
  echo "$line" | tee -a "$LOG"
  if [ "$code" = "200" ]; then
    return 0
  fi
  if [ "$required" = "true" ]; then
    echo "FAIL: required service $name is down (HTTP $code)" | tee -a "$LOG"
    return 1
  else
    echo "WARN: optional service $name unreachable (HTTP $code) -- expected when its session is stopped" | tee -a "$LOG"
    return 0
  fi
}

STATUS=0
check "Cloady hello-world" "https://hello-world-mw4vpn58-workspace-md7wee.cloady.io" true || STATUS=1
# Orca tunnel URL changes on every Kaggle restart; update ORCA_BASE_URL when it changes.
ORCA_BASE_URL="${ORCA_BASE_URL:-https://revealed-wheels-exposure-storage.trycloudflare.com}"
check "Orca /v1/models" "$ORCA_BASE_URL/v1/models" false
check "Supabase project" "https://rfftwywzshcxqslmonjw.supabase.co" false

if [ "$STATUS" -eq 0 ]; then
  echo "RESULT: OK -- required services healthy" | tee -a "$LOG"
else
  echo "RESULT: FAIL -- a required service is down" | tee -a "$LOG"
  exit 1
fi
