-- [nfnl] Compiled from fnl/live-rename.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("live-rename")
local keys = {submit = {{"n", "<cr>"}, {"v", "<cr>"}, {"i", "<cr>"}}, cancel = {{"n", "<esc>"}, {"n", "q"}, {"n", "<C-c>"}}}
local hl = {current = "CurSearch", others = "Search"}
return M.setup({prepare_rename = true, request_timeout = 5000, keys = keys, hl = hl})
