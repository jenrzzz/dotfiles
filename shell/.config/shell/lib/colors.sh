# colors.sh — terminal color palette (tput with a raw-ANSI fallback). Sourced by
# the prompt and anything that wants $RED/$GREEN/etc. Idempotent.
# Defines & exports: RED MAGENTA ORANGE GREEN PURPLE WHITE CYAN MINT TEAL
#                    SCHOOLBUS LIME BOLD RESET
#
# (Extracted from the old .bash_prompt. The original never defined LIME/CYAN/…
# in the <256-color fallback yet used $LIME in PS1 — fixed here: every branch
# defines and exports the full palette.)

[ -n "${__COLORS_SH:-}" ] && return 0 2>/dev/null || __COLORS_SH=1

if command -v tput >/dev/null 2>&1 && tput setaf 1 >/dev/null 2>&1; then
  if [ "$(tput colors 2>/dev/null || echo 0)" -ge 256 ]; then
    RED=$(tput setaf 124);       MAGENTA=$(tput setaf 9);   ORANGE=$(tput setaf 172)
    GREEN=$(tput setaf 34);      PURPLE=$(tput setaf 141);  WHITE=$(tput setaf 246)
    CYAN=$(tput setaf 45);       MINT=$(tput setaf 73);     TEAL=$(tput setaf 30)
    SCHOOLBUS=$(tput setaf 208); LIME=$(tput setaf 40)
  else
    RED=$(tput setaf 1);   MAGENTA=$(tput setaf 5);  ORANGE=$(tput setaf 4)
    GREEN=$(tput setaf 2); PURPLE=$(tput setaf 1);   WHITE=$(tput setaf 7)
    CYAN=$(tput setaf 6);  MINT=$(tput setaf 6);     TEAL=$(tput setaf 6)
    SCHOOLBUS=$(tput setaf 3); LIME=$(tput setaf 2)
  fi
  BOLD=$(tput bold); RESET=$(tput sgr0)
else
  RED="\033[1;31m";       MAGENTA="\033[1;31m"; ORANGE="\033[1;33m"
  GREEN="\033[1;32m";     PURPLE="\033[1;35m";  WHITE="\033[1;37m"
  CYAN="\033[1;36m";      MINT="\033[1;36m";    TEAL="\033[1;36m"
  SCHOOLBUS="\033[1;33m"; LIME="\033[1;32m";    BOLD=""; RESET="\033[m"
fi
export RED MAGENTA ORANGE GREEN PURPLE WHITE CYAN MINT TEAL SCHOOLBUS LIME BOLD RESET
