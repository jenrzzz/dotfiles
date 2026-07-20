#!/usr/bin/env bash
#
# tmux-claude-titles-loop.sh — once per second, keep the hub windows (👻/😍) linked at
# indices 0/1 of every session and refresh window titles. Runs continuously and no-ops
# whenever no tmux server is up, so it can be owned by a long-lived supervisor. On macOS
# it's started by a LaunchAgent (com.jenner.tmux-claude-titles); on other systems from
# .tmux.conf via `run-shell -b`. A pidfile guard keeps a single instance per user (macOS
# ships no `flock`), so a LaunchAgent copy and any run-shell copy can't double-run.

set -uo pipefail

# launchd (and a bare `run-shell`) can hand us the C locale with no LANG/LC_*. In C locale
# tmux sanitizes the TAB separators in our `-F` format strings into '_', which breaks the
# worker's `IFS=$'\t' read` parsing (every pane row gets skipped). Force a UTF-8 ctype so
# tabs survive, regardless of who launches us.
export LC_CTYPE="${LC_CTYPE:-UTF-8}"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hub="$here/tmux-hub-windows.sh"
worker="$here/tmux-claude-titles.sh"
statuslines="$here/tmux-status-lines.sh"
pidfile="${TMPDIR:-/tmp}/tmux-claude-titles.pid"

# Bail out if a previous loop is still running. The PID must be both alive *and* actually
# this script: $TMPDIR is a stable per-user path on macOS that survives reboots, so a pidfile
# can outlive the boot that wrote it. After a reboot the recorded PID is often reused by an
# unrelated process — checking `kill -0` alone would then make every new loop bail forever
# (renaming silently dies until the stale pidfile is removed).
self="$(basename "${BASH_SOURCE[0]}")"
if [[ -f "$pidfile" ]]; then
	old="$(cat "$pidfile" 2>/dev/null || true)"
	if [[ -n "$old" ]] && kill -0 "$old" 2>/dev/null \
		&& ps -p "$old" -o command= 2>/dev/null | grep -q "$self"; then
		exit 0
	fi
fi
echo $$ > "$pidfile"
trap 'rm -f "$pidfile"' EXIT

while true; do
	if tmux has-session 2>/dev/null; then
		"$hub" 2>/dev/null || true
		"$worker" 2>/dev/null || true
		"$statuslines" 2>/dev/null || true
	fi
	sleep 1
done
