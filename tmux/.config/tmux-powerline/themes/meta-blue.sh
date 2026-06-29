#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034  # palette vars are consumed by meta-base.sh after sourcing
# Meta devserver theme — bold Meta-blue accent (brighter than local jenner). Same widgets as
# jenner; palette only. Note: closest of the four to the local blue theme. Layout: meta-base.sh.
META_ACCENT=39;   META_WIN_ACCENT=39
META_FLEET_BG=17; META_FLEET_FG=75
META_HOST_BG=27;  META_HOST_FG=231
source "${TMUX_POWERLINE_DIR_USER_THEMES}/meta-base.sh"
