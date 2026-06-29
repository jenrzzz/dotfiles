#!/usr/bin/env bash
#
# tmux-status-lines.sh — size each session's status bar to its window count.
#
# A session with a lot of windows gets a *two-line* status bar (the window list on its own
# full-width row, the powerline left/right segments on a second row); sessions with few
# windows stay single-line. This reuses tmux-powerline's built-in dual-line machinery
# (see main.tmux), but applies it per session via `set-option -t <session>` instead of the
# global `-g`, so the two scopes coexist cleanly and reverting is just `set-option -u`.
#
# tmux does NOT wrap the window list across arbitrarily many rows; two-line mode just gives
# the window list a dedicated full-width row (~doubling capacity before it truncates).
#
# Idempotent: a per-session @twoline marker records the current mode, so steady state issues
# zero `set-option` calls (no redraw churn). Run once per second by tmux-claude-titles-loop.sh.
#
# Tunable: TMUX_TWOLINE_THRESHOLD (default 6) — non-hub window count at/above which a
# session switches to two lines.

set -uo pipefail

# Shared excluded-window helpers (is_excluded_name / EXCLUDE_NAMES for the 👻/😍 hubs).
. "$(dirname "${BASH_SOURCE[0]}")/lib/tmux-session-lib.sh"

# Resolve the dual-line format strings exactly as main.tmux does. Sourcing the powerline
# config files only sets env vars (the `tmux set-option` calls live in main.tmux), so this
# has no side effects on the running server.
TMUX_POWERLINE_DIR_HOME="$HOME/.tmux/plugins/tmux-powerline"
# shellcheck source=/dev/null
[ -f "$TMUX_POWERLINE_DIR_HOME/config/defaults.sh" ] && . "$TMUX_POWERLINE_DIR_HOME/config/defaults.sh"
_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/config.sh"
# shellcheck source=/dev/null
[ -f "$_cfg" ] && . "$_cfg"

# Bail if we couldn't resolve the window-list format (powerline not installed / unreadable).
fmt_window="${TMUX_POWERLINE_STATUS_FORMAT_WINDOW:-${TMUX_POWERLINE_STATUS_FORMAT_WINDOW_DEFAULT:-}}"
fmt_left="${TMUX_POWERLINE_STATUS_FORMAT_LEFT:-${TMUX_POWERLINE_STATUS_FORMAT_LEFT_DEFAULT:-}}"
fmt_right="${TMUX_POWERLINE_STATUS_FORMAT_RIGHT:-${TMUX_POWERLINE_STATUS_FORMAT_RIGHT_DEFAULT:-}}"
[ -n "$fmt_window" ] || exit 0

THRESHOLD="${TMUX_TWOLINE_THRESHOLD:-6}"

# In two-line mode the window row gets its own background so it "floats" instead of sitting
# on the powerline bar colour (the default status-style bg is a dark grey). Default is pure
# black (colour16 = #000000, not ANSI colour0 which terminals theme as grey); use "default"
# for the terminal's own bg (transparent), or any tmux colour. NOTE: on macOS the loop runs
# from a LaunchAgent with no shell env, so the env override below won't reach it — edit this
# default to change the colour there. We override window-status-style per-session (not the
# global status-style) so only the window row changes and the segment row keeps the bar look.
WIN_BG="${TMUX_TWOLINE_WINDOW_BG:-colour16}"
base_ws="$(tmux show-options -gqv window-status-style 2>/dev/null)"
base_wcs="$(tmux show-options -gqv window-status-current-style 2>/dev/null)"

# The window-list format resets to the "default" style (= status-style) in the gaps around
# window cells, so the global status-style bg (a grey bar) bleeds through even when the cells
# are black. For two-line sessions we override status-style's bg to WIN_BG so "default" is
# black too (window row = just text, no grey), then re-fill the *segment* row with the
# original bar colour (BAR_BG) so the bottom row keeps its powerline bar unchanged.
base_ss="$(tmux show-options -gqv status-style 2>/dev/null)"
BAR_BG="${base_ss##*bg=}"; BAR_BG="${BAR_BG%%,*}"; BAR_BG="${BAR_BG:-colour234}"

# Row assignment mirrors main.tmux: TMUX_POWERLINE_WINDOW_STATUS_LINE=0 puts the window
# list on row 0 (top) and the left/right segments on row 1; anything else swaps them.
if [ "${TMUX_POWERLINE_WINDOW_STATUS_LINE:-0}" != "1" ]; then
	win_row=0; lr_row=1
else
	win_row=1; lr_row=0
fi

while IFS= read -r s; do
	[[ -n "$s" ]] || continue

	# Skip sessions whose status bar the user has explicitly hidden — don't force one on.
	[[ "$(tmux show-options -qv -t "$s" status)" == "off" ]] && continue

	# Count non-hub windows (the 👻/😍 hubs are linked into every session and shouldn't count).
	count=0
	while IFS= read -r wname; do
		is_excluded_name "$wname" && continue
		count=$(( count + 1 ))
	done < <(tmux list-windows -t "$s" -F '#{window_name}' 2>/dev/null)

	desired=0; (( count >= THRESHOLD )) && desired=1
	cur="$(tmux show-options -qv -t "$s" @twoline)"; cur="${cur:-0}"
	[[ "$desired" == "$cur" ]] && continue

	if [[ "$desired" == 1 ]]; then
		tmux set-option -t "$s" status 2
		# Make "default" black so the window row is just text on black (no grey bleed)…
		tmux set-option -t "$s" status-style "${base_ss:+$base_ss,}bg=$WIN_BG"
		# …#[fill] paints each row's empty space: black for the window row, the original bar
		# colour for the segment row (so the bottom row keeps its powerline bar).
		tmux set-option -t "$s" "status-format[$win_row]" "#[fill=$WIN_BG]$fmt_window"
		tmux set-option -t "$s" "status-format[$lr_row]" "#[fill=$BAR_BG]$fmt_left"
		tmux set-option -a -t "$s" "status-format[$lr_row]" "$fmt_right"
		tmux set-option -t "$s" window-status-style "${base_ws:+$base_ws,}bg=$WIN_BG"
		tmux set-option -t "$s" window-status-current-style "${base_wcs:+$base_wcs,}bg=$WIN_BG"
		tmux set-option -t "$s" @twoline 1
	else
		# Revert to the single-line globals main.tmux set (status "on", default status-format,
		# the powerline-bar status + window styles).
		tmux set-option -u -t "$s" status
		tmux set-option -u -t "$s" status-style
		tmux set-option -u -t "$s" status-format
		tmux set-option -u -t "$s" window-status-style
		tmux set-option -u -t "$s" window-status-current-style
		tmux set-option -t "$s" @twoline 0
	fi
done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)
