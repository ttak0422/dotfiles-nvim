-- [nfnl] Compiled from fnl/vimade.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("vimade")
local blocklist = {default = {buf_opts = {buftype = {"prompt", "terminal"}}, win_config = {relative = true}}}
local fadelevel = 0.5
local recipe = {minimalist = {animate = false}}
return M.setup({blocklist = blocklist, fadelevel = fadelevel, recipe = recipe})
