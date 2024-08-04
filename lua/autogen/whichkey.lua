-- [nfnl] Compiled from fnl/whichkey.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("which-key")
local plugins = {presets = {operators = false}}
local icons = {keys = {Up = "\226\134\145", Down = "\226\134\147", Left = "\226\134\144", Right = "\226\134\146", C = "\243\176\152\180 ", M = "\243\176\152\181 ", D = "\243\176\152\179 ", S = "\243\176\152\182 ", CR = "\243\176\140\145 ", Esc = "\243\177\138\183 ", ScrollWheelDown = "\243\177\149\144 ", ScrollWheelUp = "\243\177\149\145 ", NL = "\243\176\140\145 ", BS = "\243\176\129\174 ", Space = "_", Tab = "\243\176\140\146 ", F1 = "F1", F2 = "F2", F3 = "F3", F4 = "F4", F5 = "F5", F6 = "F6", F7 = "F7", F8 = "F8", F9 = "F9", F10 = "F10", F11 = "F11", F12 = "F12"}, mappings = false}
return M.setup({plugins = plugins, icons = icons})
