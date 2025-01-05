-- [nfnl] Compiled from fnl/timerly.fnl by https://github.com/Olical/nfnl, do not edit.
local timerly = require("timerly")
local api = require("timerly.api")
local mapping
local function _1_(buf)
  return vim.keymap.set("n", "<CR>", api.togglestatus, {buffer = buf})
end
mapping = _1_
local function _2_()
  return vim.notify("Start timer", "info")
end
local function _3_()
  return vim.notify("Time's up!")
end
return timerly.setup({minutes = {25, 5}, on_start = _2_, on_finish = _3_, mapping = mapping, position = "bottom-right"})
