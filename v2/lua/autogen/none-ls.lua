-- [nfnl] Compiled from v2/fnl/none-ls.fnl by https://github.com/Olical/nfnl, do not edit.
local null_ls = require("null-ls")
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting
local utils = require("null-ls.utils")
local sources
local function _1_()
  return require("null-ls.util").root_has_file({"tsconfig.json", "package.json", "jsconfig.json", ".node_project"})
end
sources = {diagnostics.actionlint, diagnostics.checkmake, diagnostics.checkstyle, diagnostics.deadnix, diagnostics.dotenv_linter, diagnostics.editorconfig_checker, diagnostics.gitlint, diagnostics.ktlint, diagnostics.selene, diagnostics.staticcheck, diagnostics.statix, diagnostics.stylelint, diagnostics.vint, diagnostics.yamllint, formatting.prettier.with({prefer_local = "node_modules/.bin", runtime_condition = _1_}), require("none-ls.diagnostics.eslint"), formatting.biome, formatting.fantomas, formatting.fnlfmt, formatting.gofumpt, formatting.goimports, formatting.google_java_format, formatting.ktlint, formatting.nixfmt, formatting.shfmt, formatting.stylelint, formatting.stylua, formatting.tidy, formatting.yamlfmt, formatting.yapf}
null_ls.setup({border = "none", cmd = {"nvim"}, debounce = 300, default_timeout = 20000, diagnostic_config = {}, diagnostics_format = "#{m} (#{s})", fallback_severity = vim.diagnostic.severity.ERROR, log_level = "warn", notify_format = "[null-ls] %s", on_attach = nil, on_init = nil, on_exit = nil, root_dir = utils.root_pattern({".null-ls-root", ".git"}), root_dir_async = nil, should_attach = nil, temp_dir = nil, sources = sources, debug = false, update_in_insert = false})
local function _2_()
  return vim.cmd("NullLsInfo")
end
vim.api.nvim_create_user_command("NoneLsInfo", _2_, {})
local function _3_()
  return vim.cmd("NullLsLog")
end
return vim.api.nvim_create_user_command("NoneLsLog", _3_, {})
