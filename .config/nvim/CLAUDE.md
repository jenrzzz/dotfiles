# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim configuration. It lives in a dotfiles repo: `~/.config` is a symlink to
`~/.dotfiles/.config`, so editing files here is editing the live config. There is no build or
test suite — "running" the config means launching `nvim` (or `:source` / restart to pick up
changes).

## Architecture

The config is **hybrid Vimscript + Lua**, and the entry point is `init.vim` (not `init.lua`).
`init.vim` sets base options and then loads everything else in a deliberate order:

1. `lua require("setup")` — bootstraps lazy.nvim and declares plugin-level setup
2. `lua require("lspconfigs")` — LSP / formatter setup
3. `lua require("functions")` — Lua helper globals (e.g. `toggle_diagnostics`)
4. `runtime functions.vim` — Vimscript functions used by mappings/commands
5. colorscheme selection (light vs dark keyed off `$ITERM_PROFILE`)
6. `runtime mappings.vim`, `highlights.vim`, then `autocommands.vim`

Because mappings call functions, **order matters**: a mapping in `mappings.vim` that calls a
function must have that function already defined in `functions.vim`/`functions.lua`. The Lua
helpers in `functions.lua` are intentionally **global** (not module returns) so Vimscript
mappings can call them via `:lua`.

### Plugins (`lua/setup.lua` + `lua/plugins.lua`)

- `plugins.lua` returns the plugin spec table; `setup.lua` calls `require("lazy").setup("plugins", …)`.
- lazy.nvim is configured with `url_format = "git@github.com:%s.git"` — plugins are cloned over
  **SSH**, so a working GitHub SSH key is required for installs/updates.
- `setup.lua` also holds the inline `.setup()` calls for plugins that need config at startup
  (Comment, leap, other-nvim, mini.align, and the large nvim-treesitter textobjects block).
- `lazy-lock.json` pins plugin commits — commit changes to it when updating plugins.

### LSP & formatting (`lua/lspconfigs.lua`)

- TypeScript via `typescript-tools.nvim` (semantic tokens disabled, styled-components plugin).
- Ruby (`ruby_lsp`, adds a custom `:ShowRubyDeps` command) and Python (`pylsp`) are enabled
  through the **new** `vim.lsp.config(...)` / `vim.lsp.enable(...)` API.
- Formatting is routed through `none-ls` (prettier); the `<space>f` format keymap filters to
  the `null-ls` client specifically so prettier wins over LSP formatters.
- All buffer-local LSP keymaps (`gd`, `gr`, `K`, `<space>rn`, `<space>ca`, …) are set in the
  shared `LspAttach` autocommand, not per-server.

### Keybindings

`<leader>` is `,`. General-purpose mappings live in `mappings.vim`; LSP mappings are in the
`LspAttach` callback in `lspconfigs.lua`; treesitter textobject/motion mappings are in the
`nvim-treesitter` block in `setup.lua`. When adding a binding, put it in the layer that owns it.

## Common tasks

- Apply config changes: restart `nvim`, or `:source %` / `:source $MYVIMRC`.
- Manage plugins: `:Lazy` (install/update/sync), `:TSUpdate` for treesitter parsers.
- TS test for current file: `<leader>j` (runs `npx jest %`, defined in `ftplugin/typescript.vim`).

## Notes

- `old.init.vim` is a legacy archived config — not loaded. Don't treat it as current.
- Filetype-specific overrides go in `ftplugin/` (e.g. `typescript.vim`, `typescriptreact.vim`).
