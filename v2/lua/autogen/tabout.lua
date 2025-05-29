-- [nfnl] v2/fnl/tabout.fnl
local tabout = require("tabout")
local tabouts = {{open = "'", close = "'"}, {open = "\"", close = "\""}, {open = "`", close = "`"}, {open = "(", close = ")"}, {open = "[", close = "]"}, {open = "{", close = "}"}, {open = "<", close = ">"}}
return tabout.setup({tabkey = "<Tab>", backwards_tabkey = "<S-Tab>", default_tab = "<C-t>", default_shift_tab = "<C-d>", enable_backwards = true, tabouts = tabouts, act_as_shift_tab = false, act_as_tab = false, completion = false, ignore_beginning = false})
