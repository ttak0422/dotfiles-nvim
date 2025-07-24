-- [nfnl] v2/fnl/noice.fnl
local noice = require("noice")
local lsp = {progress = {enabled = true}, signature = {enabled = false}, hover = {silent = true}, override = {["vim.lsp.util.convert_input_to_markdown_lines"] = true, ["vim.lsp.util.stylize_markdown"] = true}}
local routes
local function _1_(message)
  return (vim.tbl_get(message.opts, "progress", "client") == "null-ls")
end
routes = {{filter = {event = "lsp", kind = "progress", any = {{cond = _1_}}}, opts = {skip = true}}}
return noice.setup({lsp = lsp, routes = routes})
