# 00-path.sh — PATH construction. We PREPEND our directories rather than resetting
# PATH wholesale, so we never clobber paths the environment already set up (most
# importantly the devbox's asdf shims in /opt/asdf). Homebrew paths come from
# `brew shellenv` (run in .bash_profile), not hardcoded here.

# Prepend $1 to PATH iff it's a real directory and not already present.
# Defined here (first fragment) so later fragments can use it too.
path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}

# User-local bins (highest priority).
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.bin"

# Language/tool bins, each guarded by existence.
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.yarn/bin"
path_prepend "$HOME/.config/yarn/global/node_modules/.bin"

export PATH
