-- [nfnl] v2/fnl/better-escape.fnl
local be = require("better_escape")
return be.setup({mappings = {i = {j = {k = "<Esc>"}}, c = {}, t = {j = {k = "<C-\\><C-n>"}}, v = {}, s = {}}, default_mappings = false})
