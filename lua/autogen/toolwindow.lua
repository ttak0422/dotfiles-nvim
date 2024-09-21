-- [nfnl] Compiled from fnl/toolwindow.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("toolwindow")
local qf_open
local function _1_()
  local pos = vim.api.nvim_win_get_cursor(0)
  local view = vim.fn.winsaveview()
  vim.cmd("copen")
  vim.cmd("wincmd p")
  vim.api.nvim_win_set_cursor(0, pos)
  return vim.fn.winrestview(view)
end
qf_open = _1_
local qf_close
local function _2_()
  return vim.cmd("cclose")
end
qf_close = _2_
return M.register("qf", nil, qf_close, qf_open)
