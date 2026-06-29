-- Meta (work devserver) runtime configuration.
--
-- Called from lua/setup.lua (M.setup) and lua/lspconfigs.lua (M.lsp) ONLY on hosts
-- with /usr/share/fb-editor-support/nvim. Ported from the pre-Stow devserver config.
-- The personal/macOS config never calls these, so it stays clean. Plugin specs that
-- back this up live in lua/meta_plugins.lua.
local M = {}

-- Plugin-level Meta setup: filetype detection, telescope extensions, metamate, slog.
function M.setup()
  require("plenary.filetype").add_file("meta")

  require("telescope").load_extension("fzf")
  require("telescope").load_extension("myles")
  require("telescope").load_extension("biggrep")
  require("telescope").load_extension("hg")

  require("meta").setup()

  -- Known core modules to hide from the slog trace while debugging.
  local TRACE_FILTER_RULES = {
    exact = {
      ["www/unknown"] = 1,
      ["flib/init/zeusgodofthunder/__entrypoint.php"] = 1,
      ["flib/init/routing/ZeusGodOfThunderAlite.php"] = 1,
    },
    startswith = {
      "flib/purpose/cipp/",
      "flib/core/asio/",
    },
  }
  require("meta.slog").setup({
    filters = {
      log = function(log)
        local level = log.attributes.level
        if level == "mustfix" or level == "fatal" or level == "slog" then
          return true
        end
        return false
      end,
      trace = function(trace)
        local filename = require("meta.slog.util").get_relative_filename(trace.fileName)
        if TRACE_FILTER_RULES.exact[filename] ~= nil then
          return false
        end
        if vim.tbl_contains(TRACE_FILTER_RULES.startswith, function(prefix)
          return vim.startswith(filename, prefix)
        end, { predicate = true }) then
          return false
        end
        return true
      end,
    },
  })

  require("meta.metamate").init({
    completionKeymap = "<C-_>",
    filetypes = { "php", "python", "javascript" },
  })
end

-- LSP-level Meta setup: Meta language servers + arclint (none-ls) + hhvm.
function M.lsp()
  local meta = require("meta")
  require("meta.lsp")
  vim.lsp.enable({
    "fb-pyright-ls@meta",
    "pyre@meta",
    "pyre-codenav@meta",
    "thriftlsp@meta",
    "eslint@meta",
    "prettier@meta",
    "flow@meta",
    "hhvm",
    "linttool@meta",
    "relay@meta",
  })

  vim.lsp.config("fb-pyright-ls@meta", {})

  local fmt_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
  local null_ls = require("null-ls")
  null_ls.setup({
    sources = {
      meta.null_ls.diagnostics.arclint,
      meta.null_ls.formatting.arclint,
    },
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = fmt_augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = fmt_augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end
    end,
  })

  vim.lsp.config("hhvm", {
    cmd = { "hh_client", "lsp", "--from", "vim" },
  })
end

return M
