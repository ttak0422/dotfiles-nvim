-- [nfnl] v2/fnl/timerly.fnl
local timerly = require("timerly")
local api = require("timerly.api")
local function _1_(buf)
  return vim.keymap.set("n", "<CR>", api.togglestatus, {buffer = buf})
end
return timerly.setup({position = "top-right", mapping = _1_})
