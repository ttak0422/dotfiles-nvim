-- [nfnl] Compiled from fnl/reacher.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("reacher")
local m = vim.keymap.set
local o = {noremap = true, silent = true, buffer = true}
local pattern = {"reacher"}
local callback
local function _1_()
  m("i", "<cr>", M.finish, o)
  m("i", "<esc>", M.cancel, o)
  m("i", "<C-c>", M.cancel, o)
  m("i", "<C-n>", M.next, o)
  m("i", "<C-p>", M.previous, o)
  m("i", "<Down>", M.forward_history, o)
  return m("i", "<Up>", M.backward_history, o)
end
callback = _1_
return vim.api.nvim_create_autocmd({"FileType"}, {pattern = pattern, callback = callback})
