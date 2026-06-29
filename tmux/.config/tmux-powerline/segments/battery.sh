# shellcheck shell=bash
# Override of the built-in battery segment. Upstream prints a permanent "🔌" on any machine with
# no battery (desktop/server, desktop Mac). We render nothing in that case so powerline drops the
# segment entirely. Laptop behavior (percentage / cute) is preserved by delegating to upstream's
# battery detection. The right-side statusline already shows load + hostname, so no textual
# fallback is needed here.

# Pull in upstream's helpers: __battery_osx, __battery_linux, __cutinate, __process_settings,
# BATTERY_* glyphs. (Sourcing only defines functions/vars — no top-level side effects.)
source "${TMUX_POWERLINE_DIR_SEGMENTS}/battery.sh"

run_segment() {
	__process_settings

	# Silent pre-check on Linux: bail before upstream's __battery_linux noisily cats nonexistent
	# /sys/class/power_supply/BAT* files (and divides by zero) on a desktop. Glob stays literal
	# when there's no match, so `[ -d ]` is false and we exit cleanly.
	if ! shell_is_osx; then
		local _bat _have_bat=0
		for _bat in /sys/class/power_supply/BAT*; do
			[ -d "$_bat" ] && _have_bat=1 && break
		done
		[ "$_have_bat" = 1 ] || return 0
	fi

	local battery_status
	if shell_is_osx; then
		battery_status=$(__battery_osx)
	else
		battery_status=$(__battery_linux)
	fi

	# No battery present -> emit nothing so powerline drops the segment (instead of "🔌").
	[ -n "$battery_status" ] || return 0

	case "$TMUX_POWERLINE_SEG_BATTERY_TYPE" in
	"percentage")
		echo "${battery_status}%"
		;;
	"cute")
		__cutinate "$battery_status"
		;;
	esac
}
