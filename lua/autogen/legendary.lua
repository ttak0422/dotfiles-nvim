-- [nfnl] Compiled from fnl/legendary.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("legendary")
local keymaps = {}
local commands = {{":so $VIMRUNTIME/syntax/hitest.vim", description = "Show highlights"}}
local funcs = {{Snacks.notifier.show_history, description = "Show notification history"}}
local autocmds = {}
return M.setup({col_separator_char = "", keymaps = keymaps, commands = commands, funcs = funcs, autocmds = autocmds, include_builtin = false, include_legendary_cmds = false})
