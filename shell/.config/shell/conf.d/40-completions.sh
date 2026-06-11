# 40-completions.sh — bash completion. (Bash only; the zsh stub handles its own.)
[ -n "$BASH_VERSION" ] || return 0

# Core bash-completion (Homebrew on mac, system package on linux).
if [ -n "${BREW_PREFIX:-}" ] && [ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
    . "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
elif [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Personal completion snippets, plus Homebrew's completion drop-in dir.
_compdirs="$HOME/.bash-completion"
[ -n "${BREW_PREFIX:-}" ] && _compdirs="$_compdirs $BREW_PREFIX/etc/bash_completion.d"
for _d in $_compdirs; do
    [ -d "$_d" ] || continue
    for _f in "$_d"/*; do [ -r "$_f" ] && . "$_f"; done
done
unset _compdirs _d _f

# macOS-only completions.
if is_mac; then
    complete -W "NSGlobalDomain" defaults
    complete -o nospace -W "Contacts Calendar Dock Finder Mail Safari Music SystemUIServer Terminal" killall
fi
