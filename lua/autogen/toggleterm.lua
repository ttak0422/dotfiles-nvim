-- [nfnl] Compiled from fnl/toggleterm.fnl by https://github.com/Olical/nfnl, do not edit.
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
return M.setup({size = size, start_in_insert = true, winbar = {enabled = false}, auto_scroll = false, shade_terminals = false})
