-- LSP configuration.
--
-- Servers are enabled with the native Neovim 0.11 API (vim.lsp.enable), using the
-- config definitions shipped by nvim-lspconfig. We enable only the servers we use
-- for personal projects; they no-op where the server binary isn't installed (e.g.
-- a work devserver where Meta's prepackaged plugin handles its own languages), so
-- this cooperates rather than conflicts.
--
-- Keymaps: Neovim 0.11 already maps K (hover), grr (references), grn (rename),
-- gra (code action), gri (implementation), gO (symbols), and [d/]d (diagnostics)
-- on LspAttach. We only add go-to-definition, which isn't a default. These bind to
-- whatever LSP attaches, including the work plugin's.

-- ruby_lsp: drop the (noisy) semantic tokens and add a :ShowRubyDeps command.
local function add_ruby_deps_command(client, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
    local params = vim.lsp.util.make_text_document_params()
    local showAll = opts.args == "all"
    client:request("rubyLsp/workspace/dependencies", params, function(error, result)
      if error then
        print("Error showing deps: " .. error)
        return
      end
      local qf_list = {}
      for _, item in ipairs(result) do
        if showAll or item.dependency then
          table.insert(qf_list, {
            text = string.format("%s (%s) - %s", item.name, item.version, item.dependency),
            filename = item.path,
          })
        end
      end
      vim.fn.setqflist(qf_list)
      vim.cmd("copen")
    end, bufnr)
  end, { nargs = "?", complete = function() return { "all" } end })
end

vim.lsp.config("ruby_lsp", {
  on_attach = function(client, buffer)
    client.server_capabilities.semanticTokensProvider = nil
    add_ruby_deps_command(client, buffer)
  end,
})

vim.lsp.enable({ "ruby_lsp", "pylsp", "ts_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    -- Neovim 0.11+ provides grr/grn/gra/gri/gO and [d/]d as defaults, but NOT K
    -- or gd — so map the ones we actually rely on explicitly.
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  end,
})

-- Meta work-host LSP servers (pyre/hhvm/thrift/eslint/…) + arclint formatting.
-- No-op off Meta hosts so the personal config above is unaffected.
if vim.fn.isdirectory("/usr/share/fb-editor-support/nvim") == 1 then
  require("meta_local").lsp()
end
