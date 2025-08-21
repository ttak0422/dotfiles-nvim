-- [nfnl] v2/fnl/harpoon.fnl
local harpoon = require("harpoon")
local function _1_()
  return vim.loop.cwd()
end
return harpoon.setup({settings = {key = _1_, save_on_toggle = false, sync_on_ui_close = false}})
