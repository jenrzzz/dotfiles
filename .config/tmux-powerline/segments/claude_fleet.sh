# shellcheck shell=bash
# Claude fleet summary: how many windows are running Claude across ALL sessions, and how many
# of those are idle / awaiting your input (shown as an amber ● badge). The counts are published
# once per second by bin/tmux-claude-titles.sh into the @claude_fleet global option, formatted
# as "<total> <attn>". The segment hides itself when no Claude windows are running.

run_segment() {
	local fleet total attn out
	fleet="$(tmux show-option -gqv @claude_fleet 2>/dev/null)"
	[ -z "$fleet" ] && return 0
	total="${fleet%% *}"
	attn="${fleet##* }"
	[ "${total:-0}" -gt 0 ] || return 0

	out="${total}✳"
	if [ "${attn:-0}" -gt 0 ]; then
		out="${out}  #[fg=colour214]${attn}●#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]"
	fi
	echo "${out}"
	return 0
}
