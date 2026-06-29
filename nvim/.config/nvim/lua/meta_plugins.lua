-- Meta (work devserver) plugin specs.
--
-- Loaded by lua/plugins.lua ONLY on hosts with /usr/share/fb-editor-support/nvim
-- (Meta's prepackaged nvim plugin, "meta.nvim"). This keeps the personal/macOS
-- config pristine — these specs were ported from the pre-Stow devserver config and
-- only ever activate where the Meta plugin dir exists. Runtime wiring (LSP, telescope
-- extensions, metamate, slog) lives in lua/meta_local.lua.
return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- must run as the first plugin in your config
    config = true,
  },
  "mfussenegger/nvim-dap",
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      vim.keymap.set("n", "<LEADER>ds", function()
        dap.toggle_breakpoint()
        dap.continue()
        dapui.open()
      end)
      vim.keymap.set("n", "<LEADER>dx", function()
        dap.terminate()
        dap.clear_breakpoints()
        dapui.close()
      end)
      vim.keymap.set("n", "<LEADER>dc", dap.continue)
      vim.keymap.set("n", "<LEADER>dn", dap.step_over)
      vim.keymap.set("n", "<LEADER>di", dap.step_into)
      vim.keymap.set("n", "<LEADER>do", dap.step_out)
      vim.keymap.set("n", "<LEADER>dbt", dap.toggle_breakpoint)
      vim.keymap.set("n", "<LEADER>dbx", dap.clear_breakpoints)
      vim.keymap.set("n", "<LEADER>dbl", dap.list_breakpoints)
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { dir = "/usr/share/fb-editor-support/nvim", name = "meta.nvim", dependencies = { "mfussenegger/nvim-dap" } },

  -- hg / mercurial (Meta uses hg/Sapling)
  "phleet/vim-mercenary",

  {
    "tpope/vim-projectionist",
    config = function()
      local jest_alternate = {
        ["**/__tests__/*.test.js"] = {
          alternate = "{}.js",
          type = "test",
        },
        ["*.js"] = {
          alternate = "{dirname}/__tests__/{basename}.test.js",
          type = "source",
        },
      }
      vim.g.projectionist_heuristics = {
        ["jest.config.js|jest.config.ts"] = jest_alternate,
        [".arcconfig"] = vim.tbl_deep_extend("keep", {
          ["**/__tests__/*Test.php"] = {
            alternate = "{}.php",
            type = "test",
          },
          ["*.php"] = {
            alternate = "{dirname}/__tests__/{basename}Test.php",
            type = "source",
          },
        }, jest_alternate),
      }
    end,
  },
  "tpope/vim-dispatch",
  "hhvm/vim-hack",
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
