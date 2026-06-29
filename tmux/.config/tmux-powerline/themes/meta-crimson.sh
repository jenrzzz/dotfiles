#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034  # palette vars are consumed by meta-base.sh after sourcing
# Meta devserver theme — crimson accent. Same widgets as jenner; palette only. Layout: meta-base.sh.
META_ACCENT=203;  META_WIN_ACCENT=203
META_FLEET_BG=52; META_FLEET_FG=210
META_HOST_BG=124; META_HOST_FG=231
source "${TMUX_POWERLINE_DIR_USER_THEMES}/meta-base.sh"
