-- [nfnl] Compiled from fnl/_search.fnl by https://github.com/Olical/nfnl, do not edit.
local lasterisk = require("lasterisk")
local hlslens = require("hlslens")
hlslens.setup()
local function _1_()
  lasterisk.search()
  return hlslens.start()
end
return vim.keymap.set("n", "*", _1_)
