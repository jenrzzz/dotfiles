# shellcheck shell=bash
# Lists all tmux sessions with their window counts, highlights the current session,
# and flags sessions over the bloat threshold with a ⚠ (a nudge to run `C-a R`).
# Assumes [ -n "$TMUX" ].

TMUX_POWERLINE_SEG_SESSIONS_BLOAT_THRESHOLD="${TMUX_POWERLINE_SEG_SESSIONS_BLOAT_THRESHOLD:-6}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# A session with at least this many windows is flagged with a ⚠ in the status bar.
export TMUX_POWERLINE_SEG_SESSIONS_BLOAT_THRESHOLD="${TMUX_POWERLINE_SEG_SESSIONS_BLOAT_THRESHOLD}"
EORC
	echo "$rccontents"
}

run_segment() {
	local cur fg out="" name wins label piece
	cur="$(tmux display-message -p '#S' 2>/dev/null)"
	fg="${TMUX_POWERLINE_CUR_SEGMENT_FG:-colour255}"

	while IFS=$'\t' read -r name wins; do
		[[ -n "$name" ]] || continue
		label="${name}·${wins}"
		(( wins >= TMUX_POWERLINE_SEG_SESSIONS_BLOAT_THRESHOLD )) && label="⚠ ${label}"

		if [[ "$name" == "$cur" ]]; then
			piece="#[bold]#[fg=colour117]${label}#[fg=${fg}]#[nobold]"
		elif (( wins >= TMUX_POWERLINE_SEG_SESSIONS_BLOAT_THRESHOLD )); then
			piece="#[fg=colour214]${label}#[fg=${fg}]"
		else
			piece="${label}"
		fi
		out+="${piece}  "
	done < <(tmux list-sessions -F '#{session_name}	#{session_windows}' 2>/dev/null)

	echo "${out%  }"
	return 0
}
