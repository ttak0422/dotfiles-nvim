-- [nfnl] Compiled from fnl/spectre.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("spectre")
local opts = {default = {find = {cmd = "rg", options = {}}, replace = {cmd = "sd"}}, color_devicons = false, is_block_ui_break = false, live_update = false}
return M.setup(opts)
