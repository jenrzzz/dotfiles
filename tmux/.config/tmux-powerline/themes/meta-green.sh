#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034  # palette vars are consumed by meta-base.sh after sourcing
# Meta devserver theme — green accent. Same widgets as jenner; palette only. Layout: meta-base.sh.
META_ACCENT=78;   META_WIN_ACCENT=78
META_FLEET_BG=22; META_FLEET_FG=84
META_HOST_BG=28;  META_HOST_FG=231
source "${TMUX_POWERLINE_DIR_USER_THEMES}/meta-base.sh"
