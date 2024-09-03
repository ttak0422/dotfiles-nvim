-- [nfnl] Compiled from fnl/markview.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("markview")
local modes = {"n", "no", "c"}
local hybrid_modes = {"n"}
local callbacks
local function _1_(_, win)
  vim.wo[win]["conceallevel"] = 3
  vim.wo[win]["concealcursor"] = "c"
  return nil
end
callbacks = {on_enable = _1_}
return M.setup({modes = modes, hybrid_modes = hybrid_modes, callbacks = callbacks})
