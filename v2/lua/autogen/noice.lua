-- [nfnl] v2/fnl/noice.fnl
local noice = require("noice")
local lsp = {progress = {enabled = true}, signature = {enabled = false}, hover = {silent = true}, override = {["vim.lsp.util.convert_input_to_markdown_lines"] = true, ["vim.lsp.util.stylize_markdown"] = true}}
return noice.setup({lsp = lsp})
