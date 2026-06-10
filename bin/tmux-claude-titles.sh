#!/usr/bin/env bash
#
# tmux-claude-titles.sh — session-aware window titles for Claude Code.
#
# For every window, sets two tmux user options that the powerline theme renders as
# the window name (see .config/tmux-powerline/themes/jenner.sh):
#
#   @ctitle  Claude Code's live activity (its OSC pane title) for Claude windows;
#            unset for every other window (so the theme falls back to #W).
#   @cdir    "<basename>: " when this window's directory differs from its session's
#            "average" (most common) directory; unset otherwise.
#
# Baseline = the full path the most windows in the session share (plurality). When the
# top count is tied across >=2 distinct paths there is no baseline, so every window in
# that session shows its directory.
#
# Run once per second by tmux-claude-titles-loop.sh.

set -euo pipefail

# Shared Claude-detection / exclusion / grouping helpers.
. "$(dirname "${BASH_SOURCE[0]}")/lib/tmux-session-lib.sh"

# Per-window state, keyed by window_id (e.g. "@7"), which is unique across sessions.
declare -A win_session   # window_id -> session_name
declare -A win_name      # window_id -> window_name
declare -A win_path      # window_id -> active pane cwd
declare -A win_claude    # window_id -> 1 if any pane is Claude
declare -A win_activity  # window_id -> Claude pane_title
declare -A win_state     # window_id -> "working" | "attn" (Claude windows only)

while IFS=$'\t' read -r session wid wname active cmd path title; do
	[[ -n "$wid" ]] || continue
	win_session["$wid"]="$session"
	win_name["$wid"]="$wname"
	# Prefer the active pane's path; otherwise take the first pane we see.
	if [[ "$active" == "1" || -z "${win_path[$wid]:-}" ]]; then
		win_path["$wid"]="$path"
	fi
	if is_claude_cmd "$cmd"; then
		win_claude["$wid"]=1
		win_activity["$wid"]="$title"
	fi
done < <(tmux list-panes -a -F '#{session_name}	#{window_id}	#{window_name}	#{pane_active}	#{pane_current_command}	#{pane_current_path}	#{pane_title}')

# Tally how many windows sit in each path, per session (excluded windows don't count).
declare -A path_count
for wid in "${!win_session[@]}"; do
	is_excluded_name "${win_name[$wid]}" && continue
	key="${win_session[$wid]}"$'\x1f'"${win_path[$wid]}"
	path_count["$key"]=$(( ${path_count["$key"]:-0} + 1 ))
done

# Determine each session's baseline path (unique plurality) and whether it's tied.
declare -A session_baseline   # session -> baseline path ("" if no unique baseline)
declare -A session_topcount   # session -> highest window count seen
declare -A session_tied       # session -> 1 if the top count is shared by >1 path
for key in "${!path_count[@]}"; do
	session="${key%%$'\x1f'*}"
	path="${key#*$'\x1f'}"
	count="${path_count[$key]}"
	top="${session_topcount[$session]:-0}"
	if (( count > top )); then
		session_topcount["$session"]=$count
		session_baseline["$session"]="$path"
		session_tied["$session"]=0
	elif (( count == top )); then
		session_tied["$session"]=1
	fi
done

# Apply per-window options.
for wid in "${!win_session[@]}"; do
	session="${win_session[$wid]}"
	path="${win_path[$wid]}"

	# Baseline exists only when the top count is not tied.
	baseline=""
	if [[ "${session_tied[$session]:-0}" != "1" ]]; then
		baseline="${session_baseline[$session]:-}"
	fi

	if is_excluded_name "${win_name[$wid]}" || [[ -n "$baseline" && "$path" == "$baseline" ]]; then
		tmux set-option -uw -t "$wid" @cdir 2>/dev/null || true
	else
		tmux set-option -w -t "$wid" @cdir "$(basename "$path"): "
	fi

	if [[ -n "${win_claude[$wid]:-}" ]]; then
		tmux set-option -w -t "$wid" @ctitle "${win_activity[$wid]}"
		# State for the powerline attention flag + fleet count: Claude's title leads with a
		# braille spinner (⠂⠄⠠…) while it's working, and with ✳ when it's idle / awaiting you.
		if [[ "${win_activity[$wid]}" == "✳"* ]]; then
			win_state["$wid"]="attn"
		else
			win_state["$wid"]="working"
		fi
		tmux set-option -w -t "$wid" @cstate "${win_state[$wid]}"
	else
		tmux set-option -uw -t "$wid" @ctitle 2>/dev/null || true
		tmux set-option -uw -t "$wid" @cstate 2>/dev/null || true
	fi
done

# Publish a fleet summary for the powerline claude_fleet segment: total Claude windows and how
# many are idle/awaiting input. Stored as "<total> <attn>" in a global tmux option.
claude_total=0
claude_attn=0
for wid in "${!win_claude[@]}"; do
	claude_total=$(( claude_total + 1 ))
	if [[ "${win_state[$wid]:-}" == "attn" ]]; then
		claude_attn=$(( claude_attn + 1 ))
	fi
done
tmux set-option -g @claude_fleet "$claude_total $claude_attn"
