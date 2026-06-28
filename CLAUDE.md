# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal **cross-platform** dotfiles (macOS + Linux/Coder devboxes), cloned to `~/.dotfiles`. There
is **no build or test suite** — the repo *is* the live environment. Everything is installed with
**GNU Stow**: each top-level directory is a Stow *package* whose tree mirrors `$HOME`, so editing a
file here edits the running config directly (most of `~/.config` is symlinks back into this repo).

The most substantial custom code is the **tmux session/window automation** under `scripts/bin/`
(see below). Neovim has its own config and its own `.config/nvim/CLAUDE.md` — go there for nvim,
don't duplicate it here.

## Layout — Stow packages

Each dir is a package; `stow <pkg>` symlinks its tree into `$HOME`:

- `shell/`   → `.bash_profile`, `.bashrc`, `.profile`, and `~/.config/shell/{lib,conf.d}`
- `git/`     → `.gitconfig` (+ `~/.config/git/{ignore,local.example}`)
- `tmux/`    → `.tmux.conf` + vendored `~/.tmux/plugins/tmux-powerline` (no TPM, no submodule)
- `nvim/`    → `~/.config/nvim`
- `mutt/`    → `~/.mutt` (neomutt)
- `cli/`     → assorted rc files (`.inputrc`, `.curlrc`, `.gemrc`, …) + `~/.config` bits
- `scripts/` → `scripts/bin/*` to **`~/bin`** (on PATH); tmux automation + `dot-secrets`
- `secrets/` → `~/.config/dot-secrets/manifest.tsv` (wiring only, no secrets)
- `launchd/` → `~/Library/LaunchAgents/*` (**macOS only**)
- `attic/`   → dropped legacy, kept for reference; **never stowed**

`bootstrap.sh` and `Makefile` enumerate the package set; `attic/` and the root infra files
(`Brewfile`, `packages.txt`, `README.md`, etc.) are never stow candidates.

## Setup / install

- `./bootstrap.sh [--yes] [--no-install] [--with-secrets] [--only-core] [--packages "…"]` —
  the Stow installer. It ensures `stow`, optionally installs OS packages (`brew bundle` on mac;
  `apt`/`dnf` from `packages.txt` on Linux), clears dangling legacy symlinks, backs up any
  pre-existing real file that would block a stow target (`*.pre-stow.bak`), then
  `stow --restow --no-folding` every package (`launchd` mac-only). `--with-secrets` runs
  `dot-secrets sync`.
- `make` — thin wrappers: `bootstrap` / `stow` / `core` / `unstow` / `secrets` / `packages`.
- macOS packages: `Brewfile` (`brew bundle`). Linux packages: `packages.txt` (apt/dnf names).
- Coder/headless one-liner:
  `git clone https://github.com/jenrzzz/dotfiles ~/.dotfiles && ~/.dotfiles/bootstrap.sh --yes --with-secrets`

**`--no-folding` is mandatory** so `shell`/`tmux`/`nvim`/`cli` can all contribute into one *real*
`~/.config` instead of one package folding it into a single symlink.

## Cross-platform foundation

`~/.config/shell/lib/platform.sh` is the **single source of truth** for "what OS am I on / what's
available here", sourced by bash and the tmux helpers. It exposes: `OS` (mac|linux|other), `ARCH`,
`BREW_PREFIX`, `XDG_CONFIG_HOME`; predicates `is_mac` / `is_linux` / `is_tmux` / `has <cmd>`; and
wrappers `clip`/`clipout` (pbcopy ↔ wl-clipboard ↔ xclip ↔ xsel), `openurl`, `cpu_count`,
`is_dark_mode`, and `gnu <coreutil>` (resolves `gstat`/`gdate` on mac, plain names on Linux). Put
new platform forks here, not inline.

## Shell config layout

`.bash_profile` is a thin orchestrator: source `platform.sh` → `colors.sh` → `brew shellenv`
(guarded) → every `~/.config/shell/conf.d/*.sh` in order → bash `shopt`s → optional
`~/.config/shell/private.sh` overlay (untracked, host-specific; materialized by `dot-secrets`,
simply absent elsewhere).

Per-topic config lives in `conf.d/` (numeric-ordered): `00-path` · `10-exports` · `20-aliases` ·
`30-functions` · `40-completions` · `50-tool-init` (asdf/pyenv/direnv/zoxide/fzf, each guarded by
`has`) · `90-prompt`. Add an alias → `20-aliases.sh`; a function → `30-functions.sh`; PATH →
`00-path.sh`. Keep fragments POSIX-ish and platform-guarded via `platform.sh`.

## Secrets (`dot-secrets`)

`~/bin/dot-secrets sync` materializes per-host secrets from Vaultwarden/Bitwarden into `$HOME` as
real `0600` files **outside any Stow package**, so they can never be committed or stowed. The
mapping lives in `~/.config/dot-secrets/manifest.tsv` (item → destination; tracked, no secret
content). Rows whose vault item is absent are skipped, so a host without (say) mutt access just
skips the fastmail rows. `bw unlock` is the one unavoidable prompt. Git signing config etc. land in
the untracked `~/.config/git/local` (included by `.gitconfig`), so hosts without it don't fail.

## tmux automation (`scripts/bin/tmux-*` → `~/bin`)

Prefix is `C-a`. Config: `.tmux.conf`; statusline is the **vendored** `~/.tmux/plugins/tmux-powerline`
with the `jenner` theme + custom segments. User-facing keybinding reference: `TMUX-CHEATSHEET.md`.

**Shared library — change behavior here, not per-script.** Every `tmux-*` script sources
`~/bin/lib/tmux-session-lib.sh`, which centralizes:
- `is_claude_cmd` — a pane is "running Claude" when its foreground command looks like a version
  string (the `claude` binary's process name is its version, e.g. `2.1.169`). Update here if
  Claude's process naming changes.
- `EXCLUDE_NAMES` / `HUB_GLYPHS` — the two fixed-purpose "hub" windows `👻` (htop) and `😍` (mutt):
  never get a directory prefix, don't count toward a session's baseline dir, and stay put during
  refactor/merge.
- `sanitize_session_name`, `window_dir_basename`, `move_window_to_session` (create-if-missing).

**Background loop.** On macOS a LaunchAgent (`launchd/`) runs `~/bin/tmux-claude-titles-loop.sh`;
`.tmux.conf` also launches it via `run-shell -b` (no-ops while no tmux server is up). Once per second
(single instance via a pidfile — macOS has no `flock`) it runs:
- `tmux-hub-windows.sh` — keeps the `👻`/`😍` hub windows *linked* into every session at indices
  0/1 (one real htop/mutt, mirrored everywhere). Idempotent.
- `tmux-claude-titles.sh` — sets the `@ctitle` / `@cdir` tmux user options the powerline theme
  renders as live, session-aware window titles. `@ctitle` = Claude's live activity for Claude
  windows; `@cdir` = a `basename:` prefix shown only when a window's dir differs from its session's
  plurality ("baseline") dir.

**On-demand tools** (bound in `.tmux.conf`, nothing moves automatically):
- `C-a J` → `tmux-sessionizer` — fuzzy jump-to / create-a session over running sessions + project
  dirs + `zoxide` history. Discovery roots are `PROJECT_ROOTS` in that script (OS-defaulted).
- `C-a M` → `tmux-move-window` — move current window to another / new session.
- `C-a P` → `tmux-merge-windows` — fold other windows of this session into the current one as tiled panes.
- `C-a R` → `tmux-refactor-session` — split a bloated session into one session per directory basename.

Scripts are bash with `set -uo pipefail`, source the lib via a `BASH_SOURCE`-relative path, source
`platform.sh`, and depend on `fzf` and `tmux`; the popup tools assume they run inside `display-popup -E`.

## Testing on Linux

`test/linux.sh {build|up|sh|exec|gate}` drives an Ubuntu container faithful to the Coder devbox
(repo bind-mounted, asdf/ripgrep/fd/fzf/stow/git-delta preinstalled). `test/linux.sh gate` is the
fresh-clone gate: clones the repo inside the container, runs `bootstrap.sh`, and asserts a clean
full install (no stow conflicts, all symlinks resolve, login shell clean, tmux+powerline render).
