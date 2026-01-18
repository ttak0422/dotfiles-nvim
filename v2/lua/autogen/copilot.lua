-- [nfnl] v2/fnl/copilot.fnl
local copilot = require("copilot")
local panel = {keymap = {jump_prev = "[[", jump_next = "]]", accept = "<CR>", refresh = "gr", open = "<M-CR>"}, layout = {position = "bottom", ratio = 0.4}, auto_refresh = false}
local suggestion = {enabled = (vim.g.copilot or false), auto_trigger = true, hide_during_completion = true, debounce = 150, keymap = {accept = "<C-x><C-x>", next = "<M-]>", prev = "<M-[>", dismiss = "<M-e>", accept_line = false, accept_word = false}}
local filetypes = {["."] = false, gitrebase = false, help = false}
return copilot.setup({panel = panel, suggestion = suggestion, filetypes = filetypes})
