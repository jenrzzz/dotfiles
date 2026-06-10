#!/usr/bin/env bash
#
# tmux-claude-titles-loop.sh — once per second while the tmux server is alive, keep the
# hub windows (👻/😍) linked at indices 0/1 of every session and refresh window titles.
# Started from .tmux.conf via `run-shell -b`. A pidfile guard keeps a single instance per
# server (macOS ships no `flock`).

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hub="$here/tmux-hub-windows.sh"
worker="$here/tmux-claude-titles.sh"
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

while tmux has-session 2>/dev/null; do
	"$hub" 2>/dev/null || true
	"$worker" 2>/dev/null || true
	sleep 1
done
