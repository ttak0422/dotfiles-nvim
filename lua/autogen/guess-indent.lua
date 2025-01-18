-- [nfnl] Compiled from fnl/guess-indent.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("guess-indent")
local filetype_exclude = {"netrw", "tutor"}
local buftype_exclude = {"help", "nofile", "terminal", "prompt"}
local on_tab_options = {expandtab = false}
local on_space_options = {expandtab = true, tabstop = "detected", softtabstop = "detected", shiftwidth = "detected"}
return M.setup({auto_cmd = true, filetype_exclude = filetype_exclude, buftype_exclude = buftype_exclude, on_tab_options = on_tab_options, on_space_options = on_space_options, override_editorconfig = false})
