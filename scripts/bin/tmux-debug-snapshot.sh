#!/usr/bin/env bash
#
# tmux-debug-snapshot.sh — TEMPORARY DEBUG INSTRUMENTATION.
#
# Appends a timestamped snapshot of everything relevant to the "status-right went blank"
# bug to /tmp/tmux-powerline-debug/snapshots.log: the global + per-session values of the
# status options, two-line state, client geometry, and (once per server PID) the tmux
# server's actual environment. Called from tmux-claude-titles-loop.sh every ~10s while
# ~/.config/tmux-powerline/DEBUG exists. Cheap: a handful of tmux show-options calls.
#
# Remove together with the DEBUG flag file once the fresh-devbox repro is captured.

set -uo pipefail

DBG=/tmp/tmux-powerline-debug
[ -e "${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/DEBUG" ] || exit 0
mkdir -p "$DBG" 2>/dev/null || exit 0
log="$DBG/snapshots.log"

# Keep the log bounded (~2MB): rotate once.
if [ -f "$log" ] && [ "$(wc -c < "$log")" -gt 2000000 ]; then
	mv -f "$log" "$log.1"
fi

{
	echo "=== $(date '+%F %T')"
	echo "--- global:"
	tmux show-options -g status-right
	tmux show-options -g status-left
	tmux show-options -g status-right-length
	tmux show-options -g status
	tmux show-options -g status-interval
	tmux show-options -gq status-format | head -2
	echo "--- clients: $(tmux list-clients -F '#{client_tty} #{client_width}x#{client_height} term=#{client_termname}' 2>/dev/null | tr '\n' ';')"
	while IFS= read -r s; do
		printf -- '--- session %s: status=[%s] @twoline=[%s] status-right=[%s] fmt0=[%.60s] fmt1=[%.60s]\n' \
			"$s" \
			"$(tmux show-options -qv -t "$s" status)" \
			"$(tmux show-options -qv -t "$s" @twoline)" \
			"$(tmux show-options -qv -t "$s" status-right)" \
			"$(tmux show-options -qv -t "$s" 'status-format[0]')" \
			"$(tmux show-options -qv -t "$s" 'status-format[1]')"
	done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)
} >> "$log" 2>&1

# Dump the tmux *server's* real environment once per server incarnation — this is the env
# every #() status job inherits, and the leading suspect for fresh-box-only failures.
server_pid="$(tmux display -p '#{pid}' 2>/dev/null)"
if [ -n "$server_pid" ] && [ ! -f "$DBG/server-env.$server_pid" ]; then
	{
		echo "=== tmux server pid=$server_pid started=$(ps -p "$server_pid" -o lstart= 2>/dev/null)"
		tr '\0' '\n' < "/proc/$server_pid/environ" 2>/dev/null | sort
	} > "$DBG/server-env.$server_pid" 2>&1
fi
