-- [nfnl] Compiled from fnl/showkeys.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("showkeys")
local winopts = {relative = "editor", style = "minimal", border = "single", height = 1, row = 1, col = 0, focusable = false}
local keyformat = {["<BS>"] = "\243\176\129\174 ", ["<CR>"] = "\243\176\152\140", ["<Space>"] = "\243\177\129\144", ["<Up>"] = "\243\176\129\157", ["<Down>"] = "\243\176\129\133", ["<Left>"] = "\243\176\129\141", ["<Right>"] = "\243\176\129\148", ["<PageUp>"] = "Page \243\176\129\157", ["<PageDown>"] = "Page \243\176\129\133", ["<M>"] = "Alt", ["<C>"] = "Ctrl"}
return M.setup({maxkeys = 8, position = "top-right", winopts = winopts, keyformat = keyformat})
