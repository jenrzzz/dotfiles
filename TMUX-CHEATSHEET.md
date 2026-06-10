# tmux cheat sheet

Prefix is **`C-a`** (Ctrl+A). Notation below: `C-a X` = press prefix, release, then `X`.
`★` = custom (yours); everything else is a useful default.

## Sessions — the dynamic workflow

| Key | Does |
|-----|------|
| ★ `C-a J` | **Jump or create** a session — fuzzy popup over running sessions + project dirs + `z` history. Pick a dir → switches there, creating the session if needed. |
| `C-a (` / `C-a )` | **Prev / next** session — repeatable, so hold prefix once and tap to skip across. |
| `C-a g` / `C-a L` | **Last** session (toggle back) |
| ★ `C-a S` | **Browse** all sessions/windows visually (choose-tree) |
| `C-a d` | **Detach** (session keeps running in the background) |

## Reshaping — move work around

| Key | Does |
|-----|------|
| ★ `C-a M` | **Move this window** to another (or brand-new) session |
| ★ `C-a P` | **Merge windows → panes**: multi-select (TAB) other windows, fold them into this one as tiled panes |
| ★ `C-a R` | **Refactor session**: split the current session into one session per directory (the `👻` window stays put). On-demand only. |
| `C-a <` | Window menu: **swap left / right**, kill, rename, new |
| `C-a .` | Move current window to a different index |

Statusline nudge: a session with ≥6 windows shows an amber **`⚠`** — a hint to hit `C-a R`. Nothing ever moves on its own.

## Windows

| Key | Does |
|-----|------|
| ★ `C-a c` | **New window** in the current directory |
| ★ `C-a C-h` / `C-a C-l` | **Prev / next** window (repeatable) |
| ★ `C-a r` | **Last** window (toggle back) |
| `C-a 0`–`9` | Jump to window by number |
| `C-a ,` | Rename window (note: the Claude-title script auto-names windows running Claude) |
| `C-a &` | Kill window |

## Panes

| Key | Does |
|-----|------|
| ★ `C-a h` / `j` / `k` / `l` | Select pane **left / down / up / right** (vim) |
| ★ `C-a a` | Cycle to the next pane |
| ★ `C-a ^T` | Split horizontally (25% — handy for a status pane) |
| `C-a %` / `C-a "` | Split vertical / horizontal |
| ★ `C-a ←/→/↑/↓` | Resize the current pane (repeatable) |
| `C-a z` | **Zoom** the current pane fullscreen (toggle) |
| `C-a {` / `C-a }` | Swap pane with prev / next |
| `C-a x` | Kill pane |
| `C-a !` | Break the current pane out into its own window |

## Copy mode (vi keys)

| Key | Does |
|-----|------|
| `C-a [` | Enter copy/scroll mode (`q` to exit) |
| `Space` → `Enter` | Start selection → copy (vi-style) |
| `/` `?` | Search forward / back |

## Window-name reading

- Claude windows show their **live activity** (e.g. `✳ Add progressive zoom…`).
- A `dir:` prefix appears only when a window's directory differs from its session's most common one.
- The `👻` window (htop/mutt) is always left alone.
