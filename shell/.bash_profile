# .bash_profile — login-shell orchestrator. Kept thin on purpose: it wires up the
# platform library and color palette, sets up Homebrew, then sources every
# fragment in ~/.config/shell/conf.d in order. All per-topic config lives there.

: "${XDG_CONFIG_HOME:=$HOME/.config}"
SHELL_CONFIG="$XDG_CONFIG_HOME/shell"

# 1. Platform library (OS detection + capability wrappers) — must come first.
[ -r "$SHELL_CONFIG/lib/platform.sh" ] && . "$SHELL_CONFIG/lib/platform.sh"
# 2. Color palette / theme.
[ -r "$SHELL_CONFIG/lib/colors.sh" ] && . "$SHELL_CONFIG/lib/colors.sh"

# 3. Homebrew environment (mac: /opt/homebrew or /usr/local; linux: linuxbrew).
[ -n "${BREW_PREFIX:-}" ] && [ -x "$BREW_PREFIX/bin/brew" ] && \
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"

# 4. Ordered config fragments.
if [ -d "$SHELL_CONFIG/conf.d" ]; then
    for _f in "$SHELL_CONFIG"/conf.d/*.sh; do
        [ -r "$_f" ] && . "$_f"
    done
    unset _f
fi

# 5. Bash options.
shopt -s nocaseglob histappend cdspell 2>/dev/null
for _opt in autocd globstar; do shopt -s "$_opt" 2>/dev/null; done
unset _opt

# 6. A welcome tip + fortune, just for fun, if the tools are around.
if [ -n "$PS1" ]; then
    has tips && tips
    if has fortune; then
        if has cowsay; then fortune | cowsay; else fortune; fi
    fi
fi

# 7. Private, untracked overlay (Apple/work + machine-specific bits). Sourced
#    last so it can override anything above; materialized by dot-secrets on
#    trusted hosts and simply absent everywhere else.
[ -r "$SHELL_CONFIG/private.sh" ] && . "$SHELL_CONFIG/private.sh"
