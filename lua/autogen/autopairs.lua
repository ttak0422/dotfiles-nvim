-- [nfnl] Compiled from fnl/autopairs.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
M.setup({map_cr = true, check_ts = true})
return M.add_rules({Rule("\"\"\"", "\"\"\"", "java")})
