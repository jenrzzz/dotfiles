# 90-prompt.sh — git-aware bash prompt.
#
# Theme colors are referenced through the semantic variables in the block below,
# which map onto the palette from colors.sh. To reskin the prompt, change either
# the palette (colors.sh, affects everything) or just this mapping (prompt only).
# The old macOS iTerm light/dark auto-switching (check_colors/set_profile) is gone
# — we're dark-only now.
[ -n "$BASH_VERSION" ] || return 0

# --- theme: semantic role -> palette ----------------------------------------
PROMPT_USER="${BOLD}${MAGENTA}"
PROMPT_AT="$WHITE"
PROMPT_HOST="$ORANGE"
PROMPT_PUNCT="$WHITE"
PROMPT_PATH="$LIME"
PROMPT_GIT="$PURPLE"

# --- git status helpers -----------------------------------------------------
parse_git_in_rebase() { [ -d .git/rebase-apply ] && printf ' (rebasing)'; }
parse_git_dirty() {
    git diff --exit-code &>/dev/null || printf '*'
    git diff --cached --exit-code &>/dev/null || printf '^'
}
parse_git_branch() {
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)$(parse_git_in_rebase)/"
}

# --- prompts (default + scratch) --------------------------------------------
_pg='$([[ -n $(git branch 2>/dev/null) ]] && echo " on ")\[$PROMPT_GIT\]$(parse_git_branch)'
export PS1_DEFAULT="\[$PROMPT_USER\]\u\[$PROMPT_AT\]@\[$PROMPT_HOST\]\h\[$PROMPT_PUNCT\]:\[$PROMPT_PATH\]\w\[$PROMPT_PUNCT\]${_pg}\[$PROMPT_PUNCT\]\$ \[$RESET\]"
export PS1_SCRATCH="\[$PROMPT_USER\]\u\[$PROMPT_AT\]@\[$PROMPT_HOST\]\h\[$PROMPT_PUNCT\]:\[$PROMPT_PATH\]\w\[$PROMPT_PUNCT\]${_pg}\[$PROMPT_PUNCT\] [scratch] \$ \[$RESET\]"
unset _pg
export PS1="$PS1_DEFAULT"

# --- eternal history (append every command with pid/user) -------------------
export HISTTIMEFORMAT="%s "
case "$PROMPT_COMMAND" in
    *bash_eternal_history*) ;;
    *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}"'echo "$$ $USER \"$(history 1)\"" >> ~/.bash_eternal_history' ;;
esac
