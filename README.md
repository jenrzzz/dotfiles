# jenrzzz's dotfiles

Cross-platform (macOS + Linux/Coder) dotfiles, installed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a Stow package whose tree mirrors `$HOME`.

## Install

```bash
git clone https://github.com/jenrzzz/dotfiles ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh            # ensure stow, install OS packages, then stow every package
```

Headless / Coder one-liner:

```bash
git clone https://github.com/jenrzzz/dotfiles ~/.dotfiles \
  && ~/.dotfiles/bootstrap.sh --yes --with-secrets
```

### bootstrap.sh flags

| flag | effect |
| --- | --- |
| `--yes` | non-interactive (assume yes to the package-install prompt) |
| `--no-install` | skip OS package install; just stow |
| `--with-secrets` | run `dot-secrets sync` after stowing |
| `--only-core` | stow just the portable core (no mutt/secrets/launchd) |
| `--packages "…"` | stow exactly this set |

### make targets

`make bootstrap` (full) · `make stow` · `make core` · `make unstow` · `make secrets` · `make packages`

## What's here

- **OS packages:** `Brewfile` (macOS, `brew bundle`) and `packages.txt` (Linux, apt/dnf).
- **Secrets:** `dot-secrets` materializes per-host secrets from Vaultwarden outside any package
  (`~/.config/dot-secrets/manifest.tsv` is the wiring).
- **tmux automation:** session/window tooling under `scripts/bin/` → `~/bin`; keys in `TMUX-CHEATSHEET.md`.
- **Linux testing:** `test/linux.sh gate` runs a fresh-clone install in an Ubuntu container.
- `attic/` holds dropped legacy configs, kept for reference (never stowed).

See `CLAUDE.md` for the architecture in detail.
