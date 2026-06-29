local spec = {
  { "folke/lazy.nvim", version = "*" }, -- package manager
  -- libraries
  "neovim/nvim-lspconfig",
  "nvim-lua/plenary.nvim",
  "tpope/vim-repeat",
  "glts/vim-magnum",
  "MunifTanjim/nui.nvim",
  {"nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate"},
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -- themes
  "vim-airline/vim-airline",
  "vim-airline/vim-airline-themes",
  "jenrzzz/jellybeans.vim",
  "NLKNguyen/papercolor-theme",
  "gerw/vim-HiLinkTrace",

  -- motion
  {
     url = "https://codeberg.org/andyg/leap.nvim",
  },

  -- text objects
  "tpope/vim-surround",
  "tpope/vim-speeddating",
  "tpope/vim-unimpaired",
  "glts/vim-radical",
  { 'echasnovski/mini.align', version = false },
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- git
  "tpope/vim-fugitive",
  "tommcdo/vim-fugitive-blame-ext",

  -- plugins
  "vijaymarupudi/nvim-fzf",
  "vijaymarupudi/nvim-fzf-commands",
  {"LintaoAmons/scratch.nvim", event = "VeryLazy"},
  "rgroli/other.nvim",
  "wsdjeg/vim-fetch",
  "github/copilot.vim",
  -- vim-taskwarrior echoerrs on load if the `task` binary is missing, so only
  -- load it where taskwarrior is actually installed (keeps nvim clean on devservers).
  { "farseer90718/vim-taskwarrior", cond = function() return vim.fn.executable("task") == 1 end },
  "onsails/lspkind.nvim",
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      symbols = {
        icon_source = "lspkind"
      }
    },
  },
}

-- On Meta work hosts (where the prepackaged nvim plugin exists) append the Meta-only
-- plugin specs. Personal/macOS hosts skip this entirely, keeping the config clean.
if vim.fn.isdirectory("/usr/share/fb-editor-support/nvim") == 1 then
  vim.list_extend(spec, require("meta_plugins"))
end

return spec
