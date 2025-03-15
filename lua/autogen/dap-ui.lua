-- [nfnl] Compiled from fnl/dap-ui.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("dapui")
local icons = {expanded = "\226\150\190", collapsed = "\226\150\184", current_frame = "\226\150\184"}
local controls = {element = "repl", enabled = true, icons = {disconnect = "\238\171\144", pause = "\238\171\145", play = "\238\171\147", run_last = "\238\172\183", step_back = "\238\174\143", step_into = "\238\171\148", step_out = "\238\171\149", step_over = "\238\171\150", terminate = "\238\171\151"}}
local floating = {border = "none", mappings = {close = {"q", "<Esc>"}}}
local layouts = {{elements = {{id = "scopes", size = 0.25}, {id = "breakpoints", size = 0.25}, {id = "stacks", size = 0.25}, {id = "watches", size = 0.25}}, position = "left", size = 40}, {elements = {{id = "repl", size = 0.5}, {id = "console", size = 0.5}}, position = "bottom", size = 10}}
local mappings = {edit = "e", expand = {"<CR>", "<2-LeftMouse>"}, open = "o", remove = "d", repl = "r", toggle = "t"}
local render = {indent = 1, max_value_lines = 100}
return M.setup({element_mappings = {}, expand_lines = true, force_buffers = true, icons = icons, controls = controls, floating = floating, layouts = layouts, mappings = mappings, render = render})
