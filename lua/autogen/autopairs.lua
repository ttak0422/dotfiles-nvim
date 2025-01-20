-- [nfnl] Compiled from fnl/autopairs.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local ts_config = {go = false}
local disable_filetype = {"TelescopePrompt", "spectre_panel", "norg"}
M.setup({map_cr = true, check_ts = true, ts_config = ts_config, disable_filetype = disable_filetype})
return M.add_rules({Rule("\"\"\"", "\"\"\"", "java")})
