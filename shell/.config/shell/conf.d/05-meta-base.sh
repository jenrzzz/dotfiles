# shellcheck shell=bash
# Meta host base shell environment. Sourced early (05-) so the fb-provided
# defaults land before our own aliases/functions/prompt, letting later
# fragments override them. Both files only exist on Meta hosts, so the
# `[ -r ]` guards make this a no-op everywhere else (macOS, Coder, etc.).
[ -r /etc/bashrc ] && . /etc/bashrc
[ -r /usr/facebook/ops/rc/master.bashrc ] && . /usr/facebook/ops/rc/master.bashrc
