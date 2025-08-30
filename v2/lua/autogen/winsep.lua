-- [nfnl] v2/fnl/winsep.fnl
local winsep = require("colorful-winsep")
return winsep.setup({no_exec_files = {"undotree", "gitsigns-blame"}, animate = {enabled = false}, indicator_for_2wins = {position = "center", symbols = {start_left = "", end_left = "", start_down = "", end_down = "", start_up = "", end_up = "", start_right = "", end_right = ""}}, exponential_smoothing = false, smooth = false})
