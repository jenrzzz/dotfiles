# .bashrc — sourced by interactive non-login bash. Defer to .bash_profile so
# login and non-login shells share one environment.
case $- in *i*) ;; *) return ;; esac
[ -r "$HOME/.bash_profile" ] && . "$HOME/.bash_profile"
