-- [nfnl] v2/fnl/fff.fnl
local fff = require("fff")
local keymaps = {close = {"<Esc>", "<C-c>"}, select = "<CR>", select_split = "<C-s>", select_vsplit = "<C-v>", select_tab = "<C-t>", move_up = {"<Up>", "<C-p>"}, move_down = {"<Down>", "<C-n>"}, preview_scroll_up = "<C-u>", preview_scroll_down = "<C-d>", toggle_debug = "<F2>"}
return fff.setup({keymaps = keymaps})
