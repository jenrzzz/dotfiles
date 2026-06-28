#!/usr/bin/env bash
# shellcheck shell=bash
# Default Theme
# If changes made here does not take effect, then try to re-create the tmux session to force reload.

# Cross-platform helpers (is_mac) so we can gate the macOS-only segments below. Prefer the
# dotfiles platform library; fall back to a minimal uname check if it isn't on this host.
if ! type is_mac >/dev/null 2>&1; then
	if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/lib/platform.sh" ]; then
		. "${XDG_CONFIG_HOME:-$HOME/.config}/shell/lib/platform.sh"
	else
		is_mac() { [ "$(uname -s)" = Darwin ]; }
	fi
fi

if patched_font_in_use; then
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
else
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

# See Color formatting section below for details on what colors can be used here.
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-'234'}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'74'}
# Active-window highlight is set as a tmux *base* style (window-status-current-style in
# .tmux.conf: accent blue + bold), not inline here — inline #[bold] inside this cached #()
# format string flickered on redraw. The format below is pure layout; inactive windows get
# the muted window-status-style. No background block (a filled bar lit up the whole long title).
# shellcheck disable=SC2034
TMUX_POWERLINE_SEG_AIR_COLOR=$(air_color)

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

TMUX_POWERLINE_SEG_WEATHER_UNIT="f"
# Location for the weather segment: env vars first (set per-host), then ~/.location/* files,
# else left empty so the segment is omitted below (no erroring on hosts with no location).
TMUX_POWERLINE_SEG_WEATHER_LAT="${WEATHER_LAT:-${TMUX_POWERLINE_SEG_WEATHER_LAT:-}}"
TMUX_POWERLINE_SEG_WEATHER_LON="${WEATHER_LON:-${TMUX_POWERLINE_SEG_WEATHER_LON:-}}"
if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ] && [ -r "$HOME/.location/latitude" ]; then
	TMUX_POWERLINE_SEG_WEATHER_LAT="$(tr -d '\n' < "$HOME/.location/latitude")"
fi
if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ] && [ -r "$HOME/.location/longitude" ]; then
	TMUX_POWERLINE_SEG_WEATHER_LON="$(tr -d '\n' < "$HOME/.location/longitude")"
fi

# See `man tmux` for additional formatting options for the status line.
# The `format regular` and `format inverse` functions are provided as conveniences

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
		# Bell rings as a yellow ● instead of "!"; restore the active window's accent fg after.
		"  #I#{?window_bell_flag,#[fg=colour220]▴#[fg=colour74],#{?window_flags,#F, }}"
		"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
		" #{?#{@ctitle},#{@ctitle},#{@cdir}#W}  "
	)
fi

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_STYLE" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
		"$(format regular)"
	)
fi

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_FORMAT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
		# Attention flag: an inactive window whose Claude is idle/awaiting input (@cstate=attn,
		# set by tmux-claude-titles.sh) turns amber so you can spot it without cycling windows.
		"#{?#{==:#{@cstate},attn},#[fg=colour214],}"
		# Bell rings as a yellow ● instead of the raw "!", then restore the window's base fg
		# (amber if this window is also flagged for attention, otherwise the muted gray).
		"  #I#{?window_bell_flag,#[fg=colour220]▴#{?#{==:#{@cstate},attn},#[fg=colour214],#[fg=colour244]},#{?window_flags,#F, }}"
		"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
		" #{?#{@ctitle},#{@ctitle},#{@cdir}#W}  "
	)
fi

# Format: segment_name background_color foreground_color [non_default_separator] [separator_background_color] [separator_foreground_color] [spacing_disable] [separator_disable]
# (See the upstream theme for the full option reference — trimmed here.)

# mode_indicator (leftmost): invisible in normal mode, lights up on prefix / copy-mode. Its
# per-mode text/colors are configured in ../config.sh (sourced after this theme, so it wins).

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		# both_disable + separator_disable strip powerline's wrapping spaces and the (invisible,
		# same-bg) separator cell, so in normal mode the indicator is just one blank column that
		# turns into ⌘/COPY in place — no extra left padding on the session list.
		"mode_indicator 236 244 ${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR} 236 236 both_disable separator_disable"
		"sessions 236 244"
		"claude_fleet 233 39 ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN} 234 244"
	)
fi

# Right side. now_playing/battery are macOS-only (osascript / pmset) so they're gated on is_mac;
# weather is included only when a location resolved above; the rest are portable.
# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=()
	if is_mac; then TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS+=("now_playing 233 37"); fi
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS+=("load 235 245")
	if [ -n "$TMUX_POWERLINE_SEG_WEATHER_LAT" ] && [ -n "$TMUX_POWERLINE_SEG_WEATHER_LON" ]; then
		TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS+=("weather 234 185")
	fi
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS+=(
		"date_day 235 136"
		"date 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
		"time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
		"hostname 23 255"
	)
	if is_mac; then TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS+=("battery 233 94"); fi
fi
