#!/usr/bin/env bash
#
# bootstrap.sh — install these dotfiles with GNU Stow, cross-platform.
#
# Idempotent: safe to re-run. Symlinks every package's tree into $HOME via stow,
# optionally installs the OS packages first, and optionally materializes secrets.
#
#   ./bootstrap.sh [--yes] [--no-install] [--with-secrets]
#                  [--only-core] [--packages "shell git tmux …"]
#
#   --yes            non-interactive; assume "yes" to the install-packages prompt
#   --no-install     skip the OS package install (just stow) — tools assumed present
#   --with-secrets   after stowing, run `dot-secrets sync` to fetch per-host secrets
#   --only-core      stow just the portable core (no mutt/secrets/launchd)
#   --packages "…"   stow exactly this set instead of the computed default
#
# Coder / headless one-liner:
#   git clone https://github.com/jenrzzz/dotfiles ~/.dotfiles \
#     && ~/.dotfiles/bootstrap.sh --yes --with-secrets

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="$(basename "$REPO")"

# Platform library (OS / has / is_mac / is_linux). Sourced from the repo so the
# bootstrap works before anything is stowed into $HOME.
# shellcheck source=shell/.config/shell/lib/platform.sh
. "$REPO/shell/.config/shell/lib/platform.sh"

# --- package sets -----------------------------------------------------------
# Core: portable, no external-service dependencies. mutt+secrets are portable
# too but service-ish; launchd is mac-only infra.
CORE_PKGS="shell git tmux nvim cli scripts"
EXTRA_PKGS="mutt secrets"

# --- flags ------------------------------------------------------------------
ASSUME_YES=0
DO_INSTALL=1
WITH_SECRETS=0
ONLY_CORE=0
PKGS_OVERRIDE=""

while [ $# -gt 0 ]; do
	case "$1" in
		--yes|-y)        ASSUME_YES=1 ;;
		--no-install)    DO_INSTALL=0 ;;
		--with-secrets)  WITH_SECRETS=1 ;;
		--only-core)     ONLY_CORE=1 ;;
		--packages)      shift; PKGS_OVERRIDE="${1:-}" ;;
		-h|--help)       sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
		*) printf 'bootstrap: unknown argument: %s\n' "$1" >&2; exit 2 ;;
	esac
	shift
done

log()  { printf 'bootstrap: %s\n' "$*"; }
die()  { printf 'bootstrap: %s\n' "$*" >&2; exit 1; }

# Compute the package list to stow.
if [ -n "$PKGS_OVERRIDE" ]; then
	PKGS="$PKGS_OVERRIDE"
elif [ "$ONLY_CORE" = 1 ]; then
	PKGS="$CORE_PKGS"
else
	PKGS="$CORE_PKGS $EXTRA_PKGS"
fi

# --- ensure stow ------------------------------------------------------------
ensure_stow() {
	has stow && return 0
	log "GNU Stow not found; installing it…"
	if is_mac; then
		has brew || die "Homebrew required to install stow on macOS (https://brew.sh)."
		brew install stow
	elif has apt-get; then
		sudo apt-get update -qq && sudo apt-get install -y stow
	elif has dnf; then
		sudo dnf install -y stow
	else
		die "no supported package manager (brew/apt/dnf) to install stow."
	fi
}

# --- headless git rewrite ---------------------------------------------------
# Coder boxes clone over HTTPS and have no SSH key; rewrite any git@github.com:
# remotes (the .gitconfig / submodules may use them) to HTTPS for this user.
# Write to the XDG global config ($XDG_CONFIG_HOME/git/config), NOT ~/.gitconfig:
# the git package owns ~/.gitconfig (a symlink), so --global would either create a
# conflicting real file before stow or write into the repo afterward. This file is
# read by git, not a stow target, and never tracked.
ensure_https_github() {
	is_mac && return 0   # local macs keep their SSH workflow
	mkdir -p "$XDG_CONFIG_HOME/git"
	git config --file "$XDG_CONFIG_HOME/git/config" \
		url."https://github.com/".insteadOf "git@github.com:" || true
}

# --- OS package install (optional) ------------------------------------------
install_packages_mac() {
	has brew || { log "skip install: Homebrew not present"; return 0; }
	log "brew bundle (Brewfile)…"
	brew bundle --file="$REPO/Brewfile"
}

# On Debian/Ubuntu a few tools install under alternate names or aren't packaged;
# bridge them into ~/.local/bin (already first on PATH) without sudo.
linux_shims() {
	mkdir -p "$HOME/.local/bin"
	has bat || { has batcat && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"; }
	has fd  || { has fdfind && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"; }
	if ! has eza; then
		log "installing eza release binary → ~/.local/bin…"
		local url="https://github.com/eza-community/eza/releases/latest/download/eza_${ARCH}-unknown-linux-gnu.tar.gz"
		if curl -fsSL "$url" -o /tmp/eza.tgz; then
			tar -xzf /tmp/eza.tgz -C "$HOME/.local/bin" && rm -f /tmp/eza.tgz
		else
			log "eza install failed (non-fatal)"
		fi
	fi
}

install_packages_linux() {
	local pkgs
	pkgs="$(grep -vE '^\s*#|^\s*$' "$REPO/packages.txt" | tr '\n' ' ')"
	if has apt-get; then
		log "apt-get install: $pkgs"
		sudo apt-get update -qq || true
		# shellcheck disable=SC2086  # intentional word-splitting of the package list
		sudo apt-get install -y $pkgs || log "some apt packages failed (continuing)"
		linux_shims
	elif has dnf; then
		log "dnf install: $pkgs"
		# shellcheck disable=SC2086  # intentional word-splitting of the package list
		sudo dnf install -y $pkgs || log "some dnf packages failed (continuing)"
	else
		log "no apt/dnf found; skipping package install (install manually: $pkgs)"
	fi
}

maybe_install_packages() {
	[ "$DO_INSTALL" = 1 ] || { log "skip OS package install (--no-install)"; return 0; }
	if [ "$ASSUME_YES" != 1 ]; then
		printf 'bootstrap: install OS packages first? [y/N] '
		read -r reply
		case "$reply" in [Yy]*) ;; *) log "skipping OS package install"; return 0 ;; esac
	fi
	if is_mac; then install_packages_mac; else install_packages_linux; fi
}

# --- clear the old symlink-farm so stow won't conflict ----------------------
# The legacy bootstrap `ln -s`'d these into $HOME pointing at top-level repo
# files that the package-ization deleted, so those links now DANGLE. Remove the
# dangling ones (they would block stow); current valid stow links resolve fine
# and are left for --restow to refresh.
unlink_legacy() {
	local legacy f tgt
	legacy=".ackrc .aliases .bash-completion .bash_login .bash_profile .bash_prompt \
	        .bashrc .brew .dircolors.256dark .exports .functions .gemrc .gitattributes \
	        .gitconfig .gitignore .gvimrc .hgignore .inputrc .irbrc .path .tmux.conf \
	        .screenrc .vimrc .wgetrc .zlogin .zshrc"
	for f in $legacy; do
		# only dangling symlinks (a link whose target no longer resolves)
		if ! { [ -L "$HOME/$f" ] && [ ! -e "$HOME/$f" ]; }; then continue; fi
		tgt="$(readlink "$HOME/$f")"
		case "$tgt" in
			"$REPO"/*|*/"$REPO_NAME"/*|"$REPO_NAME"/*)
				rm -f "$HOME/$f"; log "unlinked dangling ~/$f" ;;
		esac
	done
}

# --- back up pre-existing real files that would block stow ------------------
# A fresh OS image ships real $HOME dotfiles (Ubuntu's /etc/skel gives every user
# a .bashrc and .profile). Stow refuses to overlay a real file and aborts the
# whole run, so move any such conflicting file aside to *.pre-stow.bak first.
# Only touches real files / foreign symlinks at conflict paths — never our own
# stow links or real directories (which --no-folding merges into).
backup_conflicts() {
	local sim rel f
	# shellcheck disable=SC2086  # intentional word-splitting of PKGS
	sim="$(stow -n -v --dir "$REPO" --target "$HOME" --no-folding $PKGS 2>&1 || true)"
	# Match both stow message dialects:
	#   older: "existing target is neither a link nor a directory: <rel>"
	#   2.4.x: "cannot stow <pkgpath> over existing target <rel> since neither a link nor a directory…"
	printf '%s\n' "$sim" \
		| sed -n \
			-e 's/.*existing target is neither a link nor a directory: //p' \
			-e 's/.*over existing target \(.*\) since neither a link nor a directory.*/\1/p' \
		| while IFS= read -r rel; do
			[ -n "$rel" ] || continue
			f="$HOME/$rel"
			if [ -e "$f" ] && [ ! -L "$f" ] && [ ! -d "$f" ]; then
				mv "$f" "$f.pre-stow.bak"
				log "backed up pre-existing ~/$rel -> ~/$rel.pre-stow.bak"
			fi
		done
}

# --- stow -------------------------------------------------------------------
# --no-folding so shell/tmux/nvim/cli can all contribute into one real ~/.config
# (stow would otherwise fold ~/.config into a single symlink owned by one pkg).
stow_pkgs() {
	log "stow: $PKGS"
	# shellcheck disable=SC2086  # word-splitting PKGS is intentional
	stow --dir "$REPO" --target "$HOME" --restow --no-folding $PKGS
	# launchd is mac-only infra (Decision 5); stow it unless the set was trimmed
	# or explicitly overridden.
	if is_mac && [ "$ONLY_CORE" != 1 ] && [ -z "$PKGS_OVERRIDE" ]; then
		log "stow: launchd (mac)"
		stow --dir "$REPO" --target "$HOME" --restow --no-folding launchd
	fi
}

# --- secrets ----------------------------------------------------------------
sync_secrets() {
	[ "$WITH_SECRETS" = 1 ] || return 0
	local ds="$HOME/bin/dot-secrets"
	[ -x "$ds" ] || ds="$REPO/scripts/bin/dot-secrets"
	[ -x "$ds" ] || { log "dot-secrets not found; skipping secrets sync"; return 0; }
	log "syncing secrets (dot-secrets)…"
	"$ds" sync || log "dot-secrets sync had issues (see above)"
}

# --- run --------------------------------------------------------------------
log "repo: $REPO   os: $OS"
ensure_stow
ensure_https_github
maybe_install_packages
unlink_legacy
backup_conflicts
stow_pkgs
sync_secrets
log "done. open a fresh login shell (exec bash -l) to pick up the new config."
