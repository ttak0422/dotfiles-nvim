-- [nfnl] Compiled from fnl/bufferline.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("bufferline")
local bg = {attribute = "bg", highlight = "Normal"}
local fg = {attribute = "fg", highlight = "Normal"}
local rev_bg = {attribute = "fg", highlight = "Normal"}
local rev_fg = {attribute = "bg", highlight = "Normal"}
local normal = {bg = bg, fg = fg}
local active = {bg = rev_bg, fg = rev_fg}
local highlights = {fill = normal, background = normal, tab = normal, tab_selected = active, buffer_visible = {bg = bg, fg = fg, bold = true}, buffer_selected = {bg = rev_bg, fg = rev_fg, bold = true, italic = true}, modified = normal, modified_visible = normal, modified_selected = active}
local options = {indicator = {icon = "", style = "none"}, separator_style = {"", ""}, modified_icon = "\239\145\132", left_trunc_marker = "\239\132\132", right_trunc_marker = "\239\132\133", show_buffer_close_icons = false, show_buffer_icons = false, show_close_icon = false}
return M.setup({options = options, highlights = highlights})
