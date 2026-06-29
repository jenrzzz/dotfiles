#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034  # palette vars are consumed by meta-base.sh after sourcing
# Local theme — blue/cyan accent. Same widgets as the meta-* themes; palette only. The values
# below are jenner's original colors, and they equal meta-base.sh's defaults, so the local look
# is unchanged. Layout lives in meta-base.sh.
META_BG=234
META_ACCENT=74;    META_WIN_ACCENT=74
META_FLEET_BG=233; META_FLEET_FG=39
META_HOST_BG=23;   META_HOST_FG=255
source "${TMUX_POWERLINE_DIR_USER_THEMES}/meta-base.sh"
