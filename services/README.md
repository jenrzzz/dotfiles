# services (macOS-only)

macOS **Quick Actions / Services menu** entries — text services you invoke by
selecting text and right-clicking → **Services → \<name\>**.

## Not a stow package — installed by generator

Unlike the rest of the dotfiles, this is **not stowed**. Sandboxed apps
(Notes.app, etc.) refuse to read a service bundle whose files symlink out to
`~/.dotfiles` — that path is outside their sandbox container, so the read is
denied (`deny file-read-data`). The bundle must be **real files** at a path the
sandbox allows: `~/Library/Services/`.

So `build.py` is both the source of truth *and* the installer: it writes real
`.workflow` bundles straight into `~/Library/Services/` and flushes the Services
cache. No build artifact is committed — only `build.py`.

## Layout

```
services/
  build.py    # source of truth + installer
  README.md   # this file
```

`bootstrap.sh` runs `build.py` automatically on macOS (via `install_services`,
alongside the `launchd` stow). So `make bootstrap` / `make stow` install these.

## Current services

- **Render Markdown** — pipes selected Markdown through `cmark-gfm`
  (GFM: tables, strikethrough, task lists, fenced code, autolinks) → HTML →
  `textutil` → RTF, then pastes the rich text back over the selection. Tables
  come through as real tables. Great in Notes.app.

## Adding a new text service

1. Add an entry to `SERVICES` in `build.py` (a `name` and a bash `script`; the
   selected text arrives on stdin).
2. Install it:
   ```sh
   make services            # or: python3 ~/.dotfiles/services/build.py
   ```
3. Commit `build.py`.

`python3 build.py --out DIR` writes to `DIR` instead of `~/Library/Services`
(handy for inspecting the generated bundle without installing).

## Gotchas

- **Restart the target app** (e.g. Notes) after installing so it reloads the
  Services menu.
- **Accessibility permission**: services that paste via ⌘V (like Render
  Markdown) need `WorkflowServiceRunner` enabled under
  System Settings → Privacy & Security → Accessibility. Approve the first-run
  prompt. This is per-machine local state — re-approve on each machine.
- Render Markdown **replaces the clipboard** with the rendered text (needed for
  the paste).
- Depends on `cmark-gfm` (in the repo `Brewfile`).
- Uninstall a service by removing its bundle:
  `rm -rf ~/Library/Services/"<name>.workflow"`.
