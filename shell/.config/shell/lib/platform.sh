# platform.sh — cross-platform shell foundation, the single source of truth for
# "what OS am I on / what tools are available here". Sourced by bash, zsh, and
# the tmux helper scripts. Kept POSIX-ish so it works under bash/zsh/sh.
# Idempotent: safe to source more than once.
#
#   source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/lib/platform.sh"
#
# Exposes
#   vars : OS (mac|linux|other)  ARCH  BREW_PREFIX  XDG_CONFIG_HOME
#   pred : is_mac  is_linux  is_tmux  is_dark_mode  has <cmd>
#   wrap : clip / clipout (clipboard)  openurl  cpu_count  gnu <coreutil>

[ -n "${__PLATFORM_SH:-}" ] && return 0 2>/dev/null || __PLATFORM_SH=1

# --- identity ---------------------------------------------------------------
case "$(uname -s)" in
  Darwin) OS=mac   ;;
  Linux)  OS=linux ;;
  *)      OS=other ;;
esac
ARCH="$(uname -m)"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
export OS ARCH XDG_CONFIG_HOME

# --- predicates -------------------------------------------------------------
is_mac()   { [ "$OS" = mac ]; }
is_linux() { [ "$OS" = linux ]; }
is_tmux()  { [ -n "${TMUX:-}" ]; }
has()     { command -v "$1" >/dev/null 2>&1; }

# --- brew prefix (Apple Silicon, then Intel, then Linuxbrew) ----------------
BREW_PREFIX=
for _bp in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew"; do
  if [ -x "$_bp/bin/brew" ]; then BREW_PREFIX="$_bp"; break; fi
done
unset _bp
export BREW_PREFIX

# --- GNU coreutils resolver -------------------------------------------------
# macOS ships BSD coreutils; Homebrew installs the GNU ones g-prefixed (gstat,
# gdate, …). On Linux the plain names already are GNU. Resolve the right one:
#   "$(gnu stat)" -c %s file      "$(gnu date)" -d @0
gnu() { if has "g$1"; then printf 'g%s' "$1"; else printf '%s' "$1"; fi; }

# --- clipboard (pbcopy/pbpaste ↔ wl-clipboard ↔ xclip ↔ xsel) ---------------
clip() {     # stdin -> clipboard
  if   has pbcopy;  then pbcopy
  elif has wl-copy; then wl-copy
  elif has xclip;   then xclip -selection clipboard
  elif has xsel;    then xsel --clipboard --input
  else cat >/dev/null; printf 'clip: no clipboard tool found\n' >&2; return 1; fi
}
clipout() {  # clipboard -> stdout   (named clipout, not paste, to avoid shadowing the paste(1) coreutil)
  if   has pbpaste;  then pbpaste
  elif has wl-paste; then wl-paste
  elif has xclip;    then xclip -selection clipboard -o
  elif has xsel;     then xsel --clipboard --output
  else printf 'clipout: no clipboard tool found\n' >&2; return 1; fi
}

# --- misc capability wrappers ----------------------------------------------
openurl() {  # open(1) on mac, xdg-open on linux
  if   has open;     then open "$@"
  elif has xdg-open; then xdg-open "$@" >/dev/null 2>&1
  else printf 'openurl: no opener found\n' >&2; return 1; fi
}
cpu_count() { if is_mac; then sysctl -n hw.ncpu; else nproc; fi; }
is_dark_mode() {  # mac: ask the system; linux: honor $DARK_MODE from the environment
  if is_mac; then [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = Dark ]
  else [ -n "${DARK_MODE:-}" ]; fi
}
