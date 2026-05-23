-- [nfnl] v2/fnl/leap.fnl
local M = require("leap")
local clever = require("leap.user").with_traversal_keys
local clever_f = clever("f", "F")
local clever_t = clever("t", "T")
local function ft(spec)
  local _1_
  if vim.fn.mode(1):match("o") then
    _1_ = ""
  else
    _1_ = nil
  end
  return M.leap(vim.tbl_deep_extend("keep", spec, {inputlen = 1, inclusive = true, opts = {labels = "", safe_labels = _1_}}))
end
for modes, _3_ in pairs({[{"n", "x", "o"}] = {"s", "<Plug>(leap)", "Leap"}, n = {"S", "<Plug>(leap-from-window)", "Leap from window"}}) do
  local lhs = _3_[1]
  local rhs = _3_[2]
  local desc = _3_[3]
  vim.keymap.set(modes, lhs, rhs, {noremap = true, silent = true, desc = desc})
end
for key, spec in pairs({f = {opts = clever_f}, F = {backward = true, opts = clever_f}, t = {offset = -1, opts = clever_t}, T = {backward = true, offset = 1, opts = clever_t}}) do
  local function _4_()
    return ft(spec)
  end
  vim.keymap.set({"n", "x", "o"}, key, _4_)
end
for modes, _5_ in pairs({[{"n", "x", "o"}] = {"s", "<Plug>(leap)", "Leap"}, n = {"S", "<Plug>(leap-from-window)", "Leap from window"}}) do
  local lhs = _5_[1]
  local rhs = _5_[2]
  local desc = _5_[3]
  vim.keymap.set(modes, lhs, rhs, {noremap = true, silent = true, desc = desc})
end
return nil
