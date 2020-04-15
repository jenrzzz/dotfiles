# Print fortune first so we don't get bored
if command -v fortune &>/dev/null; then
    if command -v cowsay &>/dev/null; then
        if [[ `date "+%u"` =~ [567] ]]; then
            fortune -a | cowsay -sf bong
        else
            fortune | cowsay
        fi
    else
        fortune
    fi
fi

# Start powerline
if hash powerline-daemon &>/dev/null; then
  powerline-daemon -q
  export POWERLINE_PATH="/usr/local/lib/python2.7/site-packages/powerline"
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null
done


# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# If possible, add tab completion for many more commands
for file in $HOME/.bash-completion/*; do
    [ -r "$file" ] && source "$file"
done

# https://github.com/rupa/z
zpath="$(brew --prefix)/etc/profile.d/z.sh"
[ -f "$zpath" ] && source "$zpath"

# https://github.com/erichs/composure
[ -f "$HOME/bin/composure" ] && source "$HOME/bin/composure"

# Use direnv
hash direnv &>/dev/null && eval "$(direnv hook bash)"

# Use phpenv
hash phpenv &>/dev/null && eval "$(phpenv init -)"

# # Init gpg-agent if it's there
# if hash gpg-agent &>/dev/null; then
#   gpg-agent --daemon --write-env-file "$HOME/.gpg-agent-info" &>/dev/null
#   source "$HOME/.gpg-agent-info"
#   export GPG_TTY=$(tty) GPG_AGENT_INFO
# fi

# Unmap Ctrl-S and Ctrl-Q so that they'll work in vim
stty start undef stop undef

# Don't do weird shit
set -o pipefail
