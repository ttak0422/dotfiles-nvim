-- [nfnl] Compiled from fnl/autoclose.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("autoclose")
local keys = {["("] = {close = true, pair = "()", escape = false}, ["["] = {close = true, pair = "[]", escape = false}, ["{"] = {close = true, pair = "{}", escape = false}, [">"] = {escape = true, pair = "<>", close = false}, [")"] = {escape = true, pair = "()", close = false}, ["]"] = {escape = true, pair = "[]", close = false}, ["}"] = {escape = true, pair = "{}", close = false}, ["\""] = {escape = true, close = true, pair = "\"\""}, ["'"] = {escape = true, close = true, pair = "''"}, ["`"] = {escape = true, close = true, pair = "``"}}
local options = {disabled_filetypes = {"text", "spectre_panel", "norg"}, touch_regex = "[%w(%[{]", auto_indent = true, disable_command_mode = true, disable_when_touch = false, pair_spaces = false}
return M.setup({keys = keys, options = options})
