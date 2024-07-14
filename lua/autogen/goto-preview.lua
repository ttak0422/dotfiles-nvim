-- [nfnl] Compiled from fnl/goto-preview.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("goto-preview")
local border = "none"
local post_close_hook = nil
return M.setup({height = 20, width = 120, focus_on_open = true, opacity = nil, border = border, post_close_hook = post_close_hook, debug = false, dismiss_on_move = false, default_mappings = false, resizing_mappings = false})
