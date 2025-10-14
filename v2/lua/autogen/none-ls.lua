-- [nfnl] v2/fnl/none-ls.fnl
local null_ls = require("null-ls")
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting
local utils = require("null-ls.utils")
local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")
local FORMATTING = methods.internal.FORMATTING
local diagnostics_eslint = require("none-ls.diagnostics.eslint")
vim.g.idea_path = args.idea
local sources
local function _1_()
  return (vim.g.checkstyle ~= nil)
end
local function _2_(ps)
  return (ps.bufname ~= "")
end
local function _3_(_241)
  return utils.root_pattern({".eslintrc", "eslint.config.js"})(_241.bufname)
end
local function _4_()
  return (vim.g.idea_format ~= nil)
end
local function _5_()
  return {"format", "-s", vim.g.idea_format, "$FILENAME"}
end
local function _6_()
  return (vim.g.idea_format == nil)
end
local function _7_(_241)
  return (utils.root_pattern({"tsconfig.json", "package.json", "jsconfig.json", ".node_project"})(_241.bufname) and not utils.root_pattern({"rome.json", "biome.json", "biome.jsonc"})(_241.bufname))
end
local function _8_(_241)
  return utils.root_pattern({"rome.json", "biome.json", "biome.jsonc"})(_241.bufname)
end
sources = {diagnostics.actionlint, diagnostics.checkmake, diagnostics.checkstyle.with({runtime_condition = _1_, extra_args = {"-c", (vim.g.checkstyle or "/google_checks.xml")}}), diagnostics.deadnix, diagnostics.dotenv_linter, diagnostics.editorconfig_checker.with({runtime_condition = _2_}), diagnostics.gitlint, diagnostics.ktlint, diagnostics.mypy, diagnostics.selene, diagnostics.semgrep, diagnostics.sqruff, diagnostics.staticcheck, diagnostics.statix, diagnostics.stylelint, diagnostics.terraform_validate, diagnostics.vint, diagnostics.yamllint, diagnostics_eslint.with({runtime_condition = helpers.cache.by_bufnr(_3_)}), formatting.fantomas, formatting.fnlfmt, formatting.gofumpt, formatting.goimports, formatting.ktlint, formatting.nixfmt, formatting.shfmt, formatting.sqruff, formatting.stylelint, formatting.stylua, formatting.terraform_fmt, formatting.tidy, formatting.yamlfmt, formatting.yapf, helpers.make_builtin({name = "idea", method = FORMATTING, filetypes = {"java", "groovy", "kotlin"}, runtime_condition = _4_, generator_opts = {command = args.idea, args = _5_, timeout = 20000, from_temp_file = true, to_temp_file = true, to_stdin = false}, factory = helpers.formatter_factory}), formatting.google_java_format.with({runtime_condition = _6_, timeout = 20000}), formatting.prettier.with({prefer_local = "node_modules/.bin", runtime_condition = helpers.cache.by_bufnr(_7_), filetypes = {"javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less", "graphql", "handlebars", "svelte", "astro", "htmlangular"}}), formatting.biome.with({runtime_condition = helpers.cache.by_bufnr(_8_)})}
null_ls.setup({border = "none", cmd = {"nvim"}, debounce = 300, default_timeout = 10000, diagnostic_config = {}, diagnostics_format = "#{m} (#{s})", fallback_severity = vim.diagnostic.severity.ERROR, log_level = "warn", notify_format = "[null-ls] %s", on_attach = nil, on_init = nil, on_exit = nil, root_dir = utils.root_pattern({".null-ls-root", ".git"}), root_dir_async = nil, should_attach = nil, temp_dir = nil, sources = sources, debug = false, update_in_insert = false})
local function _9_()
  return vim.cmd("NullLsInfo")
end
vim.api.nvim_create_user_command("NoneLsInfo", _9_, {})
local function _10_()
  return vim.cmd("NullLsLog")
end
return vim.api.nvim_create_user_command("NoneLsLog", _10_, {})
