-- [nfnl] v2/fnl/winsep.fnl
local winsep = require("colorful-winsep")
return winsep.setup({animate = {enabled = false}, excluded_ft = {"TelescopePrompt"}, indicator_for_2wins = {position = "center", symbols = {start_left = "", end_left = "", start_down = "", end_down = "", start_up = "", end_up = "", start_right = "", end_right = ""}}})
