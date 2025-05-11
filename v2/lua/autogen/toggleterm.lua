-- [nfnl] Compiled from v2/fnl/toggleterm.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("toggleterm")
local size
local function _1_(term)
  if (term.direction == "horizontal") then
    return (vim.o.lines * 0.35)
  else
    return (vim.o.columns * 0.5)
  end
end
size = _1_
local float_opts
local function _3_()
  return math.min(vim.o.columns, 150)
end
local function _4_()
  return math.floor((vim.o.lines * 0.8))
end
float_opts = {border = "single", width = _3_, height = _4_, title_pos = "center"}
return M.setup({size = size, float_opts = float_opts, start_in_insert = true, winbar = {enabled = false}, auto_scroll = false, shade_terminals = false})
