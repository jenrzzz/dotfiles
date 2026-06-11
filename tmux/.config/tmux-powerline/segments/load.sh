# shellcheck shell=bash
# Load average (1/5/15 min), colored by 1-minute load per CPU core so it actually catches the
# eye under pressure:  <70% the segment's normal color, 70-100% amber, >=100% (oversubscribed) red.
# Overrides the built-in load segment (which prints the same numbers with no color cue).
# Cross-platform: /proc/loadavg on Linux, `sysctl vm.loadavg` on macOS.

run_segment() {
	local one five fifteen ncpu pct color
	if [ -r /proc/loadavg ]; then
		read -r one five fifteen _ < /proc/loadavg
	else
		read -r one five fifteen <<< "$(sysctl -n vm.loadavg 2>/dev/null | tr -d '{}')"
	fi
	[ -n "$one" ] || return 0

	# getconf works on both Linux and macOS; fall back to sysctl/nproc just in case.
	ncpu="$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 1)"
	pct="$(awk -v l="$one" -v n="$ncpu" 'BEGIN { if (n < 1) n = 1; printf "%d", (l / n) * 100 }')"
	if   [ "$pct" -ge 100 ]; then color="colour196"
	elif [ "$pct" -ge 70  ]; then color="colour214"
	else color=""
	fi

	if [ -n "$color" ]; then
		echo "#[fg=${color}]${one} ${five} ${fifteen}#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]"
	else
		echo "${one} ${five} ${fifteen}"
	fi
	return 0
}
