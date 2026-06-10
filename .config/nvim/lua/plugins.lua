return {
  { "folke/lazy.nvim", version = "*" }, -- package manager
  -- libraries
  "neovim/nvim-lspconfig",
  "nvim-lua/plenary.nvim",
  "tpope/vim-repeat",
  "glts/vim-magnum",
  "MunifTanjim/nui.nvim",
  {"nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate"},
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "nvimtools/none-ls.nvim",
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
  "farseer90718/vim-taskwarrior",
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
