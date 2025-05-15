-- [nfnl] Compiled from v2/fnl/none-ls.fnl by https://github.com/Olical/nfnl, do not edit.
local null_ls = require("null-ls")
local utils = require("null-ls.utils")
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting
local function lsp_active_3f(lsp_name)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({bufnr = bufnr})
  local acc = false
  for _, client in ipairs(clients) do
    acc = (acc or (lsp_name == client.name))
  end
  return acc
end
local sources
local function _1_(...)
  return not lsp_active_3f("denols")
end
sources = {diagnostics.actionlint, diagnostics.checkmake, diagnostics.checkstyle, diagnostics.deadnix, diagnostics.dotenv_linter, diagnostics.editorconfig_checker, diagnostics.gitlint, diagnostics.hodolint, diagnostics.ktlint, diagnostics.selene, diagnostics.staticcheck, diagnostics.statix, diagnostics.stylelint, diagnostics.vint, diagnostics.yamllint, require("none-ls.diagnostics.eslint"), formatting.biome, formatting.fantomas, formatting.fnlfmt, formatting.gofumpt, formatting.goimports, formatting.google_java_format, formatting.ktlint, formatting.nixfmt, formatting.prettier.with({prefer_local = "node_modules/.bin", runtime_condition = _1_}), formatting.shfmt, formatting.stylelint, formatting.stylua, formatting.tidy, formatting.yamlfmt, formatting.yapf}
return null_ls.setup({border = "none", cmd = {"nvim"}, debounce = 300, default_timeout = 50000, diagnostic_config = {}, diagnostics_format = "#{m}", fallback_severity = vim.diagnostic.severity.ERROR, log_level = "warn", notify_format = "[null-ls] %s", on_attach = nil, on_init = nil, on_exit = nil, root_dir = utils.root_pattern(".null-ls-root", "Makefile", ".git"), root_dir_async = nil, should_attach = nil, temp_dir = nil, sources = sources, debug = false, update_in_insert = false})
