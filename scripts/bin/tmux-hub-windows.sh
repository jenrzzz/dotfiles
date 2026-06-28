#!/usr/bin/env bash
#
# tmux-hub-windows.sh — keep the hub windows (👻, 😍) linked into every session at the
# first two indices. The real windows live wherever they were first created; every other
# session gets a *link* to the same window (one htop/mutt, mirrored everywhere).
#
# Idempotent and cheap: when a session already has 👻 at base+0 and 😍 at base+1 it does
# nothing. Run once per second by tmux-claude-titles-loop.sh.

set -uo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/lib/tmux-session-lib.sh"

base="$(tmux show-options -gv base-index 2>/dev/null)"; base="${base:-0}"

# Resolve each hub glyph to the window_id of an existing window with that name. Linked
# windows share one id across sessions, so the first match is canonical. Bail if either
# hub window doesn't exist anywhere (nothing to anchor — don't spawn anything).
declare -a hub_ids=()
mapfile -t all < <(tmux list-windows -a -F '#{window_id}	#{window_name}')
for glyph in "${HUB_GLYPHS[@]}"; do
	id=""
	for row in "${all[@]}"; do
		IFS=$'\t' read -r wid wname <<<"$row"
		[[ "$wname" == *"$glyph"* ]] && { id="$wid"; break; }
	done
	[[ -n "$id" ]] || exit 0
	hub_ids+=("$id")
done

# htop in the 👻 window (HUB_GLYPHS[0]) redraws constantly; with the window linked into
# every session that would trip the activity indicator everywhere. Activity monitoring is
# per-window, and this is one shared window, so disabling it once covers all sessions.
tmux set-window-option -t "${hub_ids[0]}" monitor-activity off 2>/dev/null || true

# index of window-id $1 within session $2, or empty if absent.
win_index_in() {
	local id="$1" sess="$2"
	tmux list-windows -t "=$sess" -F '#{window_id} #{window_index}' 2>/dev/null \
		| awk -v id="$id" '$1==id {print $2; exit}'
}

while IFS= read -r sess; do
	[[ -n "$sess" ]] || continue
	for slot in "${!hub_ids[@]}"; do
		id="${hub_ids[$slot]}"
		target=$(( base + slot ))

		# Link the hub window into this session if it isn't already here.
		if [[ -z "$(win_index_in "$id" "$sess")" ]]; then
			tmux link-window -d -s "$id" -t "=$sess:" 2>/dev/null || true
		fi

		# Move it to its slot (base+0 / base+1) if it isn't already there.
		cur="$(win_index_in "$id" "$sess")"
		if [[ -n "$cur" && "$cur" != "$target" ]]; then
			tmux swap-window -d -s "=$sess:$cur" -t "=$sess:$target" 2>/dev/null || true
		fi
	done
done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)
