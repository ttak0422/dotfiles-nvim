-- [nfnl] Compiled from fnl/null-ls.fnl by https://github.com/Olical/nfnl, do not edit.
local null_ls = require("null-ls")
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting
local utils = require("null-ls.utils")
local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")
local FORMATTING = methods.internal.FORMATTING
local is_active_lsp
local function _1_(lsp_name)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({bufnr = bufnr})
  local acc = false
  for _, client in ipairs(clients) do
    acc = (acc or (lsp_name == client.name))
  end
  return acc
end
is_active_lsp = _1_
local sources
local function _2_(...)
  return not is_active_lsp("denols")
end
sources = {diagnostics.staticcheck, formatting.stylua, formatting.shfmt, formatting.google_java_format, formatting.yapf, formatting.prettier.with({prefer_local = "node_modules/.bin", runtime_condition = _2_}), formatting.tidy, formatting.gofumpt, formatting.fnlfmt, formatting.nixfmt}
return null_ls.setup({border = "none", cmd = {"nvim"}, debounce = 250, default_timeout = 10000, diagnostic_config = {}, diagnostics_format = "#{m} (#{s})", fallback_severity = vim.diagnostic.severity.ERROR, log_level = "warn", notify_format = "[null-ls] %s", on_attach = nil, on_init = nil, on_exit = nil, root_dir = utils.root_pattern({".null-ls-root", ".git"}), root_dir_async = nil, should_attach = nil, temp_dir = nil, sources = sources, debug = false, update_in_insert = false})
