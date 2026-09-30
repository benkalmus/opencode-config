#!/bin/sh
# Ensures Chrome CDP is up, then hands off to Playwright MCP.
# Start (auto-launches Chrome when needed): chrome-cdp-mcp.sh
# Stop the Chrome it started: chrome-cdp-mcp.sh stop

CDP_PORT=9222
CDP_URL="http://localhost:${CDP_PORT}"
PROFILE_DIR="$HOME/.hermes/chrome-debug"
# Runtime state only, not browser data. Runtime dir clears on reboot, so no stale pids.
PIDFILE="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/chrome-cdp.pid"
CHROME_BIN="google-chrome-stable"
MAX_WAIT_SECS=15
STARTED_BY_ME=0

cdp_up() {
  curl -s -m 2 "$CDP_URL/json/version" >/dev/null 2>&1
}

recorded_pid() {
  [ -f "$PIDFILE" ] && cat "$PIDFILE" 2>/dev/null
}

is_chrome() {
  [ -n "$1" ] && ps -p "$1" -o comm= 2>/dev/null | grep -qi chrome
}

stop_chrome() {
  pid=$(recorded_pid)
  if [ -z "$pid" ]; then echo "chrome-cdp: no recorded pid"; return 1; fi
  if is_chrome "$pid"; then kill "$pid"; fi
  rm -f "$PIDFILE"
}

# Kill switch for failed starts only. Fires on early exit (timeout, Ctrl-C).
# The STARTED_BY_ME guard means it never touches a Chrome you started yourself.
cleanup_failed_start() {
  if [ "$STARTED_BY_ME" = 1 ] && ! cdp_up; then stop_chrome; fi
}

wait_for_cdp() {
  i=0
  while ! cdp_up; do
    i=$((i + 1))
    if [ "$i" -ge "$MAX_WAIT_SECS" ]; then return 1; fi
    sleep 1
  done
}

if [ "${1:-}" = "stop" ]; then stop_chrome; exit "$?"; fi

# trap hooks cleanup_failed_start into three exits: EXIT (any exit path),
# INT (Ctrl-C), TERM (kill). It stays armed only while this shell is alive.
trap cleanup_failed_start EXIT INT TERM

if ! cdp_up; then
  mkdir -p "$PROFILE_DIR"
  "$CHROME_BIN" --remote-debugging-port="$CDP_PORT" --user-data-dir="$PROFILE_DIR" --no-first-run --no-default-browser-check >/dev/null 2>&1 &
  echo "$!" > "$PIDFILE"
  STARTED_BY_ME=1
  if ! wait_for_cdp; then echo "chrome-cdp: timed out after ${MAX_WAIT_SECS}s waiting for $CDP_URL" >&2; exit 1; fi
fi

# Success path. exec swaps this shell for the MCP server, which wipes all traps.
# The reset below is belt and braces so nothing fires between here and exec.
trap - EXIT INT TERM
exec npx -y @playwright/mcp@latest --cdp-endpoint "$CDP_URL" "$@"
