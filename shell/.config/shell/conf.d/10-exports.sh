# 10-exports.sh — environment variables.

# Terminal: prefer tmux/xterm 256-color when the terminfo entry exists.
if [ -n "${TMUX:-}" ] && infocmp tmux-256color >/dev/null 2>&1; then
    export TERM=tmux-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

# Locale: US English, UTF-8.
export LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Editor.
export EDITOR=nvim VISUAL=nvim

# Pager: syntax-highlight man pages with bat when available, else plain less.
if has bat; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
else
    export MANPAGER="less -X"
fi
export LESS_TERMCAP_md="${ORANGE:-}"

# History.
export HISTSIZE=32768 HISTFILESIZE=32768
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# Go.
export GOPATH="$HOME/Source/go"
command -v path_prepend >/dev/null 2>&1 && path_prepend "$GOPATH/bin"

# pnpm (location differs by platform).
if is_mac; then export PNPM_HOME="$HOME/Library/pnpm"; else export PNPM_HOME="$HOME/.local/share/pnpm"; fi
command -v path_prepend >/dev/null 2>&1 && path_prepend "$PNPM_HOME"
export PATH

# Ansible: no cowsay.
export ANSIBLE_NOCOWS=y

# Dircolors (dark only now). Use the custom file if present, else sane defaults.
if has dircolors || has gdircolors; then
    _dc="$(gnu dircolors)"
    if [ -r "$XDG_CONFIG_HOME/shell/dircolors" ]; then
        eval "$("$_dc" "$XDG_CONFIG_HOME/shell/dircolors")"
    else
        eval "$("$_dc" -b)"
    fi
    unset _dc
fi

# fzf: drive it with fd (fallback ripgrep); include hidden files, skip .git.
if has fzf; then
    if has fd; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    elif has rg; then
        export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
    fi
    export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
fi
