#!/usr/bin/env bash
#
# tmux-session-lib.sh — shared helpers for the tmux session/title tooling.
# Source it: . "$(dirname "${BASH_SOURCE[0]}")/lib/tmux-session-lib.sh"
#
# Keeps Claude detection, the excluded-window list, session-name sanitizing, and
# directory grouping consistent across tmux-claude-titles.sh, tmux-sessionizer,
# tmux-move-window, tmux-merge-windows, and tmux-refactor-session.

# A pane is running Claude Code when its foreground command looks like a version string
# (the `claude` binary's process name is its version, e.g. "2.1.169"), or literally contains
# "claude" (belt-and-suspenders in case the process naming changes). Update if both break.
is_claude_cmd() { [[ "$1" =~ ^[0-9]+\.[0-9]+ || "$1" == *claude* ]]; }

# Windows whose name matches an entry here are fixed-purpose utility windows (the htop/mutt
# 👻 and 😍): they are linked into every session at indices 0/1 (see tmux-hub-windows.sh),
# never get a directory prefix, don't count toward a session's baseline directory, and are
# left in place when a session is refactored or merged. Matched by containment so trailing
# spaces / decorations don't matter.
EXCLUDE_NAMES=("👻" "😍")

# The two hub windows, in the order they should occupy indices base+0 and base+1.
HUB_GLYPHS=("👻" "😍")
is_excluded_name() {
	local n
	for n in "${EXCLUDE_NAMES[@]}"; do [[ "$1" == *"$n"* ]] && return 0; done
	return 1
}

# tmux uses '.' and ':' as target separators, so they can't appear in a session name.
# Map those (and whitespace) to '_' so a directory basename is always a legal name.
sanitize_session_name() {
	local name="$1"
	name="${name//[.: ]/_}"
	printf '%s' "$name"
}

# The grouping key for a window during refactor/splitting: the basename of its directory.
window_dir_basename() { basename "$1"; }

# Move a window into a session by name, creating that session (rooted at $dir) if needed.
# When creating, the placeholder window tmux opens is removed so only real windows remain.
#   move_window_to_session <src_window_id> <session_name> <fallback_dir>
move_window_to_session() {
	local src="$1" name="$2" dir="$3"
	if tmux has-session -t "=$name" 2>/dev/null; then
		tmux move-window -s "$src" -t "=$name":
	else
		tmux new-session -ds "$name" -c "$dir"
		local placeholder
		placeholder="$(tmux list-windows -t "=$name" -F '#{window_id}' | head -1)"
		tmux move-window -s "$src" -t "=$name":
		tmux kill-window -t "$placeholder" 2>/dev/null || true
	fi
}
