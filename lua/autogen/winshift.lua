-- [nfnl] Compiled from fnl/winshift.fnl by https://github.com/Olical/nfnl, do not edit.
local M = setmetatable({lib = require("winshift.lib")}, {__index = require("winshift")})
local moving_win_options = {colorcolumn = "", cursorline = false, cursorcolumn = false, wrap = false}
local keymaps = {disable_defaults = true, win_move_mode = {h = "left", j = "down", k = "up", l = "right", H = "far_left", J = "far_down", K = "far_up", L = "far_right"}}
local picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
local filter_rules = {cur_win = true, floats = true, filetype = {}, buftype = {}, bufname = {}}
local window_picker
local function _1_()
  return M.lib.pick_window({picker_chars = picker_chars, filter_rules = filter_rules})
end
window_picker = _1_
return M.setup({highlight_moving_win = true, focused_hl_group = "Visual", moving_win_options = moving_win_options, keymaps = keymaps, window_picker = window_picker})
