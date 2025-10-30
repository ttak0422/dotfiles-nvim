-- [nfnl] v2/fnl/noice.fnl
local noice = require("noice")
local lsp = {progress = {enabled = true}, signature = {enabled = false}, hover = {silent = true}, override = {["vim.lsp.util.convert_input_to_markdown_lines"] = true, ["vim.lsp.util.stylize_markdown"] = true}}
local routes
local function _1_(message)
  local _2_ = vim.tbl_get(message.opts, "progress", "client")
  if (_2_ == "null-ls") then
    return true
  elseif (_2_ == "jdtls") then
    local title = vim.tbl_get(message.opts, "progress", "title")
    return ((title == "Publish Diagnostics") or (title == "Validate documents") or ((title == "Background task") and (vim.tbl_get(message.opts, "progress", "percentage") == 0)))
  else
    local _ = _2_
    return false
  end
end
routes = {{filter = {event = "lsp", kind = "progress", any = {{cond = _1_}}}, opts = {skip = true}}}
return noice.setup({lsp = lsp, routes = routes})
