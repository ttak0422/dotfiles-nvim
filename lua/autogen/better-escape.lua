-- [nfnl] Compiled from fnl/better-escape.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("better_escape")
local mappings = {i = {j = {k = "<Esc>"}}, c = {}, t = {}, v = {}, s = {}}
return M.setup({timeout = vim.o.timeoutlen, mappings = mappings, default_mappings = false})
