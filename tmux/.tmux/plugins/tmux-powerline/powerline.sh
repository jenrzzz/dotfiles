#!/usr/bin/env bash

TMUX_POWERLINE_DIR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TMUX_POWERLINE_DIR_HOME

# --- TEMPORARY DEBUG INSTRUMENTATION (remove with ~/.config/tmux-powerline/DEBUG) -------
# When the DEBUG flag file exists, every left/right render logs a one-line summary to
# /tmp/tmux-powerline-debug/runs.log; any run that produces EMPTY output (or exits non-zero)
# additionally keeps a full dump (env + stderr + xtrace) so we can see exactly which segment
# or source line died when the status bar goes blank on a fresh box. Capped at 40 dumps.
_PL_DEBUG_DIR=""
if [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/DEBUG" ]; then
	_PL_DEBUG_DIR="/tmp/tmux-powerline-debug"
	mkdir -p "$_PL_DEBUG_DIR" 2>/dev/null || _PL_DEBUG_DIR=""
fi
# ----------------------------------------------------------------------------------------

# shellcheck source=lib/headers.sh
source "${TMUX_POWERLINE_DIR_HOME}/lib/headers.sh"

_pl_render() {
	if ! powerline_muted "$1"; then
		process_settings
		check_arg_segment "$1"
		if [ "$1" == "window-current-format" ]; then
			print_powerline_window_status_current_format
		elif [ "$1" == "window-format" ]; then
			print_powerline_window_status_format
		else
			print_powerline_side "$1"
		fi
	fi
}

if [ -n "$_PL_DEBUG_DIR" ] && { [ "${1:-}" = "left" ] || [ "${1:-}" = "right" ]; }; then
	_err="$(mktemp "$_PL_DEBUG_DIR/err.XXXXXX" 2>/dev/null)" || _err=/dev/null
	# set -x is inherited by the $( ) subshell, whose stderr (incl. xtrace) we capture into
	# $_err — so a failing/empty run's dump shows the exact code path. The few outer trace
	# lines go to the script's own stderr, which tmux discards.
	set -x
	_out="$(_pl_render "$1" 2>>"$_err")"
	_rc=$?
	set +x
	printf '%s\n' "$_out"
	printf '%s pid=%s side=%s rc=%s bytes=%s muted=%s tmux=%s\n' \
		"$(date '+%F %T')" "$$" "$1" "$_rc" "${#_out}" \
		"$(powerline_muted "$1" && echo 1 || echo 0)" "${TMUX:-none}" >> "$_PL_DEBUG_DIR/runs.log" 2>/dev/null
	if { [ -z "$_out" ] || [ "$_rc" -ne 0 ]; } && [ "$_err" != /dev/null ]; then
		_dumps=$(ls "$_PL_DEBUG_DIR"/dump.* 2>/dev/null | wc -l)
		if [ "$_dumps" -lt 40 ]; then
			_dump="$_PL_DEBUG_DIR/dump.$(date '+%H%M%S').$$.$1"
			{
				echo "=== EMPTY/FAILED render side=$1 rc=$_rc $(date '+%F %T')"
				echo "--- env:"; env | sort
				echo "--- stderr+xtrace:"; cat "$_err"
			} > "$_dump" 2>/dev/null
		fi
	fi
	rm -f "$_err" 2>/dev/null
	exit 0
fi

_pl_render "${1:-}"

exit 0
