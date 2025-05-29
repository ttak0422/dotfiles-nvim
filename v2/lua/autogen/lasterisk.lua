-- [nfnl] v2/fnl/lasterisk.fnl
local lasterisk = require("lasterisk")
local hlslens = require("hlslens")
local function _1_()
  lasterisk.search()
  return hlslens.start()
end
return vim.keymap.set("n", "*", _1_)
