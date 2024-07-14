-- [nfnl] Compiled from fnl/legendary.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("legendary")
local keymaps = {}
local commands = {{":so $VIMRUNTIME/syntax/hitest.vim", description = "enumerate highlight"}}
local functions = {}
local autocmds = {}
return M.setup({col_separator_char = "", keymaps = keymaps, commands = commands, functions = functions, autocmds = autocmds, include_builtin = false, include_legendary_cmds = false})
