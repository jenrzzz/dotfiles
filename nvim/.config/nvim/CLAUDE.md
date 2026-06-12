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
- lazy.nvim clones plugins over **https** (its default) so installs work on hosts without a
  GitHub SSH key (Coder / work devservers).
- `setup.lua` also holds the inline `.setup()` calls for plugins that need config at startup
  (Comment, leap, other-nvim, mini.align, and the large nvim-treesitter textobjects block).
- `lazy-lock.json` pins plugin commits — commit changes to it when updating plugins.

### LSP (`lua/lspconfigs.lua`)

- All servers (`ruby_lsp`, `pylsp`, `ts_ls`) are enabled through the native Neovim 0.11
  `vim.lsp.enable(...)` API, using the configs shipped by `nvim-lspconfig`. They no-op where the
  server binary isn't installed, so the config cooperates with a host's own LSP tooling (e.g.
  Meta's prepackaged plugin at work) rather than conflicting.
- `ruby_lsp` gets a per-server `vim.lsp.config` that disables semantic tokens and adds a custom
  `:ShowRubyDeps` command.
- Keymaps: Neovim 0.11+ provides `grr`/`grn`/`gra`/`gri`/`gO` and `[d`/`]d` as defaults, but
  `K` and `gd` are NOT defaults — so the `LspAttach` autocommand maps `K` (hover), `gd`
  (definition), and `gD` (declaration). Everything else comes from the Neovim defaults.
- No dedicated formatter plugin — format via the LSP (`vim.lsp.buf.format()`) or `:!prettier`.

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
