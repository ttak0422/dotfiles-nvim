-- [nfnl] Compiled from fnl/autopairs.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("nvim-autopairs")
local disable_filetype = {"TelescopePrompt", "spectre_panel", "norg"}
local Rule = require("nvim-autopairs.rule")
M.setup({map_cr = true, check_ts = true, disable_filetype = disable_filetype})
return M.add_rules({Rule("\"\"\"", "\"\"\"", "java")})
