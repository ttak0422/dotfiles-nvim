-- [nfnl] Compiled from fnl/bufferline.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("bufferline")
local options = {modified_icon = "[+]", left_trunc_marker = "\239\132\132", right_trunc_marker = "\239\132\133", show_buffer_close_icons = false, show_buffer_icons = false, show_close_icon = false}
return M.setup({options = options})