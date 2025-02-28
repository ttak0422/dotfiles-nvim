-- [nfnl] Compiled from fnl/toggler.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("toggler")
local function _1_()
  return vim.cmd("copen")
end
local function _2_()
  return vim.cmd("cclose")
end
local function _3_()
  return (vim.fn.getqflist({winid = 0}).winid ~= 0)
end
M.register("qf", {open = _1_, close = _2_, is_open = _3_})
local st = {}
local open_idx
local function _4_(idx)
  local _6_
  do
    local _5_ = st[idx]
    if (nil ~= _5_) then
      local term = _5_
      _6_ = term
    else
      local _ = _5_
      local term = require("toggleterm.terminal").Terminal:new({direction = "float"})
      st[idx] = term
      _6_ = term
    end
  end
  return _6_:open()
end
open_idx = _4_
local is_open_idx
local function _11_(idx)
  local term = st[idx]
  return (term and term:is_open())
end
is_open_idx = _11_
local close_idx
local function _12_(idx)
  local term = st[idx]
  if (term and term:is_open()) then
    return term:close()
  else
    return nil
  end
end
close_idx = _12_
for i = 0, 9 do
  local function _14_()
    return open_idx(i)
  end
  local function _15_()
    return close_idx(i)
  end
  local function _16_()
    return is_open_idx(i)
  end
  M.register(("term" .. i), {open = _14_, close = _15_, is_open = _16_})
end
return nil
