# .profile — POSIX login shim for non-bash shells (sh, dash). Bash uses
# .bash_profile and zsh uses .zshrc; this just gives a plain sh login a sane
# PATH + environment by sourcing the platform library and the two safe fragments.
: "${XDG_CONFIG_HOME:=$HOME/.config}"
SHELL_CONFIG="$XDG_CONFIG_HOME/shell"

[ -r "$SHELL_CONFIG/lib/platform.sh" ] && . "$SHELL_CONFIG/lib/platform.sh"
[ -n "${BREW_PREFIX:-}" ] && [ -x "$BREW_PREFIX/bin/brew" ] && \
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"

for _f in "$SHELL_CONFIG"/conf.d/00-path.sh "$SHELL_CONFIG"/conf.d/10-exports.sh; do
    [ -r "$_f" ] && . "$_f"
done
unset _f
