-- [nfnl] fnl/copilot.fnl
local M = require("copilot")
local keymap = {jump_prev = "[[", jump_next = "]]", accept = "<CR>", refresh = "<M-r>", open = "<M-CR>", layout = {position = "bottom", ratio = 0.4}}
local suggestion = {enabled = true, auto_trigger = true, debounce = 150, keymap = {accept = "<C-a>", next = "<M-]>", prev = "<M-[>", dismiss = "<M-e>", accept_line = false, accept_word = false}}
local filetypes = {["."] = false, gitrebase = false, help = false}
return M.setup({enabled = true, keymap = keymap, suggestion = suggestion, filetypes = filetypes, auto_refresh = false})
