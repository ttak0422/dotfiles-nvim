-- [nfnl] v2/fnl/hlchunk.fnl
local hlchunk = require("hlchunk")
local indent = {enable = false}
local line_num = {enable = false}
local blank = {enable = false}
local chunk = {enable = true, chars = {horizontal_line = "\226\148\128", vertical_line = "\226\148\130", left_top = "\226\148\140", left_bottom = "\226\148\148", right_arrow = "\226\148\128"}, style = vim.g.terminal_color_8, duration = 200, delay = 500, use_treesitter = true, exclude_filetypes = {["copilot-chat"] = true}}
return hlchunk.setup({chunk = chunk, indent = indent, line_num = line_num, blank = blank})
