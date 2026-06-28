---
description: Generate fresh workflow tips from the configs and append them to the tips database
argument-hint: "[count] (default 10)"
allowed-tools: Read, Edit, Bash(git diff:*)
---

Add new tips to the personal tips database at `scripts/.config/tips/tips.txt`
(which stows to `~/.config/tips/tips.txt` and is shown at login by `scripts/bin/tips`).

## How many

Generate **$ARGUMENTS** new tips. If `$ARGUMENTS` is empty, generate **10**.

## Steps

1. Read the existing database `scripts/.config/tips/tips.txt` in full so you can
   see every tip already present and the exact record format.
2. Read these sources of truth and mine them for genuinely useful, non-obvious tips:
   - `TMUX-CHEATSHEET.md` and `tmux/.tmux.conf` — keybindings (prefix is `C-a`) and the
     on-demand tools (tmux-sessionizer, tmux-move-window, tmux-merge-windows, tmux-refactor-session).
   - `shell/.config/shell/conf.d/20-aliases.sh` and `30-functions.sh` — aliases and shell functions.
   - `nvim/.config/nvim/mappings.vim` and `nvim/.config/nvim/CLAUDE.md` — leader is `,`; LSP maps
     are added on `LspAttach` in `lua/lspconfigs.lua`.
   - `git/.gitconfig` — git aliases and the `gh:` / `gst:` URL shorthands.
   - For `claude-code` tips, use accurate, broadly-true Claude Code features (slash commands,
     plan mode, `!` shell prefix, `@` file mentions, the skills this repo can use).
3. Write the tips. Each must:
   - be **accurate to the actual config** — verify the key/alias/function exists in the files above;
     never invent a binding. If unsure, drop it.
   - **not duplicate** anything already in the database (same binding/alias/idea — not just same wording).
   - be **1–2 lines**, concrete and actionable (name the real key or command).
   - carry a `category:` of `tmux`, `bash`, `nvim`, `git`, or `claude-code`.
4. Append them to `scripts/.config/tips/tips.txt` in the existing format: a `%` line between
   records, each record starting with `category: <name>` then the body. Do not reorder or edit
   existing entries.
5. Report what you added (count per category) and remind me I can preview with `tips -a` once stowed.
