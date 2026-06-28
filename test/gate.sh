#!/usr/bin/env bash
# In-container fresh-clone gate for the dotfiles. Runs as user `coder`.
# /src is the bind-mounted host repo (read-only use). We clone it to ~/.dotfiles
# so only TRACKED files land — exactly what a fresh Coder/GitHub clone gets.
set -uo pipefail
SRC="${SRC:-/src}"   # bind-mounted host repo; overridable
fail=0
say() { printf '\n=== %s ===\n' "$*"; }
ok()  { printf '  ✓ %s\n' "$*"; }
bad() { printf '  ✗ %s\n' "$*"; fail=1; }

say "fresh clone $SRC -> ~/.dotfiles (tracked files only)"
rm -rf ~/.dotfiles
# -c safe.directory inline (bind-mount is host-uid-owned) so we DON'T create a
# real ~/.gitconfig that would itself conflict with the git package.
git -c safe.directory='*' clone -q "$SRC" ~/.dotfiles && ok "cloned" || { bad "clone failed"; exit 1; }
cd ~/.dotfiles || { bad "cd ~/.dotfiles failed"; exit 1; }

say "bootstrap --yes --no-install (non-interactive, tools pre-baked)"
if ./bootstrap.sh --yes --no-install; then ok "bootstrap exit 0"; else bad "bootstrap nonzero exit"; fi

say "stow -n -v re-check: no conflicts (everything already linked)"
sim="$(stow -n -v --dir ~/.dotfiles --target ~ --restow --no-folding shell git tmux nvim cli scripts mutt secrets 2>&1 || true)"
if printf '%s\n' "$sim" | grep -iqE 'conflict|cannot|neither a link'; then
  bad "stow reported conflicts:"; printf '%s\n' "$sim" | grep -iE 'conflict|cannot|neither a link' | sed 's/^/    /'
else
  ok "stow dry-run clean"
fi

say "key symlinks resolve"
for f in .bash_profile .gitconfig .tmux.conf .config/nvim/init.vim bin/dot-secrets .config/dot-secrets/manifest.tsv .mutt/muttrc; do
  if [ -e ~/"$f" ]; then ok "~/$f"; else bad "~/$f missing/broken"; fi
done

say "login shell is clean (no errors) and platform detects linux"
out="$(bash -lc 'echo OS=$OS; echo BREW_PREFIX=${BREW_PREFIX:-none}; command -v dot-secrets tmux-sessionizer' 2>&1)"
echo "$out" | sed 's/^/  /'
echo "$out" | grep -q 'OS=linux' && ok "OS=linux" || bad "OS not linux"
echo "$out" | grep -q '/home/coder/bin/dot-secrets' && ok "~/bin on PATH (dot-secrets resolves)" || bad "dot-secrets not on PATH"
# any tracebacks / 'command not found' / unbound var noise?
if echo "$out" | grep -iE 'not found|unbound|error|no such'; then bad "login shell emitted errors (above)"; else ok "no login-shell errors"; fi

say "tmux config parses + powerline renders (linux segments only)"
if command -v tmux >/dev/null; then
  if tmux -f ~/.tmux.conf new-session -d -s gate 2>/tmp/tmux.err; then
    ok "tmux started with our config"
    sleep 1
    bar="$(~/.tmux/plugins/tmux-powerline/powerline.sh left 2>/tmp/pl.err || true)"
    if [ -n "$bar" ]; then ok "powerline left segment rendered"; else bad "powerline render empty (see /tmp/pl.err)"; cat /tmp/pl.err | sed 's/^/    /'; fi
    tmux kill-server 2>/dev/null || true
  else
    bad "tmux failed to start (see below)"; sed 's/^/    /' /tmp/tmux.err
  fi
else
  echo "  (tmux not installed in image — skipping)"
fi

say "nvim loads config headlessly (if nvim present)"
if command -v nvim >/dev/null; then
  if nvim --headless "+lua print('nvim-ok')" +qa 2>/tmp/nv.err; then ok "nvim loaded config"; else bad "nvim errored (see below)"; sed 's/^/    /' /tmp/nv.err; fi
else
  echo "  (nvim not installed in image — skipping; config stowed at ~/.config/nvim)"
fi

say "--with-secrets degrades gracefully without bw"
if ./bootstrap.sh --yes --no-install --with-secrets 2>&1 | tail -3 | sed 's/^/  /'; then
  ok "bootstrap --with-secrets still exit 0 (secrets skipped, no bw)"
else
  bad "bootstrap --with-secrets failed"
fi

say "make core / make unstow / make stow round-trip"
make core   >/dev/null 2>&1 && ok "make core"   || bad "make core failed"
make unstow >/dev/null 2>&1 && ok "make unstow" || bad "make unstow failed"
[ -e ~/.bash_profile ] && bad "~/.bash_profile still present after unstow" || ok "unstow removed links"
make stow   >/dev/null 2>&1 && ok "make stow"   || bad "make stow failed"
[ -e ~/.bash_profile ] && ok "~/.bash_profile restored after stow" || bad "stow did not restore links"

say "RESULT"
if [ "$fail" = 0 ]; then echo "  ALL GATE CHECKS PASSED"; else echo "  GATE FAILURES PRESENT (see ✗ above)"; fi
exit $fail
