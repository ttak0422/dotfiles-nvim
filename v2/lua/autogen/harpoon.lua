-- [nfnl] Compiled from v2/fnl/harpoon.fnl by https://github.com/Olical/nfnl, do not edit.
local harpoon = require("harpoon")
local function _1_()
  return vim.loop.cwd()
end
return harpoon.setup({settings = {key = _1_, save_on_toggle = false, sync_on_ui_close = false}})
