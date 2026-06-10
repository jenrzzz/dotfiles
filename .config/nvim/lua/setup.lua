local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  git = {
      url_format = "git@github.com:%s.git"
  },
  ui = {
      icons = {
          cmd = "⌘",
          config = "🛠",
          event = "📅",
          ft = "📂",
          init = "⚙",
          keys = "🗝", plugin = "🔌",
          runtime = "💻",
          require = "🌙",
          source = "📄",
          start = "🚀",
          task = "📌",
          lazy = "💤 ",
      },
  },
})

require('Comment').setup()
require('leap').add_default_mappings()

require('other-nvim').setup({
  mappings = {
    "rails"
  }
})

require('mini.align').setup()

-- nvim-treesitter `main` branch (required for Neovim 0.11+/0.12).
-- The `master`-branch `require'nvim-treesitter.configs'.setup{}` module system
-- is gone; parsers are managed with :TSInstall / :TSUpdate, and textobjects are
-- configured via the new module API below with explicit keymaps.
local ok_ts, nvim_treesitter = pcall(require, "nvim-treesitter")
if ok_ts then
  nvim_treesitter.setup({})
end

local ok_to, textobjects = pcall(require, "nvim-treesitter-textobjects")
if ok_to then
  textobjects.setup({
    select = {
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      -- Per-textobject selection mode (charwise 'v', linewise 'V', blockwise '<c-v>')
      selection_modes = {
        ["@parameter.outer"] = "v",
        ["@function.outer"] = "V",
        ["@class.outer"] = "<c-v>",
      },
      -- Extend the textobject to include surrounding whitespace, like built-in `ap`
      include_surrounding_whitespace = true,
    },
    move = {
      set_jumps = true, -- store movements in the jumplist
    },
  })

  local select = require("nvim-treesitter-textobjects.select")
  local swap = require("nvim-treesitter-textobjects.swap")
  local move = require("nvim-treesitter-textobjects.move")

  -- select
  local function sel(obj, group)
    return function()
      select.select_textobject(obj, group or "textobjects")
    end
  end
  vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"), { desc = "Select outer function" })
  vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"), { desc = "Select inner function" })
  vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "Select outer class" })
  vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "Select inner part of a class region" })
  vim.keymap.set({ "x", "o" }, "as", sel("@scope", "locals"), { desc = "Select language scope" })

  -- swap
  vim.keymap.set("n", "<leader>a", function() swap.swap_next("@parameter.inner") end, { desc = "Swap next parameter" })
  vim.keymap.set("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap previous parameter" })

  -- move
  local function mv(fn, obj, group)
    return function()
      fn(obj, group or "textobjects")
    end
  end
  vim.keymap.set({ "n", "x", "o" }, "]m", mv(move.goto_next_start, "@function.outer"), { desc = "Next function start" })
  vim.keymap.set({ "n", "x", "o" }, "]]", mv(move.goto_next_start, "@class.outer"), { desc = "Next class start" })
  vim.keymap.set({ "n", "x", "o" }, "]o", mv(move.goto_next_start, { "@loop.inner", "@loop.outer" }), { desc = "Next loop start" })
  vim.keymap.set({ "n", "x", "o" }, "]s", mv(move.goto_next_start, "@scope", "locals"), { desc = "Next scope" })
  vim.keymap.set({ "n", "x", "o" }, "]z", mv(move.goto_next_start, "@fold", "folds"), { desc = "Next fold" })

  vim.keymap.set({ "n", "x", "o" }, "]M", mv(move.goto_next_end, "@function.outer"), { desc = "Next function end" })
  vim.keymap.set({ "n", "x", "o" }, "][", mv(move.goto_next_end, "@class.outer"), { desc = "Next class end" })

  vim.keymap.set({ "n", "x", "o" }, "[m", mv(move.goto_previous_start, "@function.outer"), { desc = "Previous function start" })
  vim.keymap.set({ "n", "x", "o" }, "[[", mv(move.goto_previous_start, "@class.outer"), { desc = "Previous class start" })

  vim.keymap.set({ "n", "x", "o" }, "[M", mv(move.goto_previous_end, "@function.outer"), { desc = "Previous function end" })
  vim.keymap.set({ "n", "x", "o" }, "[]", mv(move.goto_previous_end, "@class.outer"), { desc = "Previous class end" })

  vim.keymap.set({ "n", "x", "o" }, "]d", mv(move.goto_next, "@conditional.outer"), { desc = "Next conditional" })
  vim.keymap.set({ "n", "x", "o" }, "[d", mv(move.goto_previous, "@conditional.outer"), { desc = "Previous conditional" })
  -- NOTE: the `main` branch dropped the `lsp_interop` module, so the old
  -- <leader>df / <leader>dF "peek definition" textobject mappings are gone.
end

