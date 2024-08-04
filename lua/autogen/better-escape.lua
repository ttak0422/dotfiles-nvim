-- [nfnl] Compiled from fnl/better-escape.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("better_escape")
local mappings = {i = {j = {k = "<Esc>"}}, c = {j = {k = "<Esc>"}}, t = {j = {k = "<Esc>"}}, v = {j = {k = "<Esc>"}}, s = {j = {k = "<Esc>"}}}
return M.setup({timeout = vim.o.timeoutlen, mappings = mappings, default_mappings = false})
