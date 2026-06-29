# 50-tool-init.sh — initialize version managers and shell tools, each guarded by
# presence so a host only pays for what it actually has installed.

# --- Runtime version manager: asdf preferred, legacy managers as fallback ----
# asdf comes in two shapes: the classic v0.14 shell script (source asdf.sh, as on
# the devbox) and the v0.16+ Go rewrite (a binary — just put its shims on PATH).
if [ -n "${ASDF_DIR:-}" ] && [ -r "$ASDF_DIR/asdf.sh" ]; then
    . "$ASDF_DIR/asdf.sh"                                  # classic 0.14
elif [ -r "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
elif has asdf; then                                       # 0.16+ binary
    path_prepend "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"; export PATH
fi

# rbenv takes precedence over asdf for Ruby: init it AFTER the asdf block so its
# shims get prepended ahead of asdf's. Resolution order becomes:
#   rbenv ruby  →  asdf ruby  →  system /usr/bin/ruby
has rbenv && eval "$(rbenv init - bash)"

# Other legacy per-language managers only if asdf isn't in charge.
if ! has asdf; then
    has nodenv && eval "$(nodenv init -)"
    has pyenv  && eval "$(pyenv init - bash)"
fi

# --- direnv ------------------------------------------------------------------
has direnv && eval "$(direnv hook bash)"

# --- zoxide (frecency cd; replaces the old z.sh) -----------------------------
has zoxide && eval "$(zoxide init bash)"

# --- fzf key bindings + completion -------------------------------------------
if has fzf; then
    if fzf --bash >/dev/null 2>&1; then                    # fzf >= 0.48
        eval "$(fzf --bash)"
    else
        for _f in \
            "$BREW_PREFIX/opt/fzf/shell/key-bindings.bash" \
            "$BREW_PREFIX/opt/fzf/shell/completion.bash" \
            /usr/share/doc/fzf/examples/key-bindings.bash \
            /usr/share/bash-completion/completions/fzf; do
            [ -r "$_f" ] && . "$_f"
        done
        unset _f
    fi
fi

# --- terraform completion (derive the path; never hardcode a version) --------
has terraform && complete -C "$(command -v terraform)" terraform

# --- ngrok -------------------------------------------------------------------
has ngrok && eval "$(ngrok completion 2>/dev/null)"

# tmuxinator once misbehaved with an inherited GEM_HOME; clear it (harmless under asdf).
unset GEM_HOME
