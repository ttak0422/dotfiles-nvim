-- [nfnl] Compiled from fnl/toggler.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("toggler")
local function with_keep_window(f)
  local function _1_()
    local win = vim.api.nvim_get_current_win()
    f()
    return vim.api.nvim_set_current_win(win)
  end
  return _1_
end
local function _2_()
  return vim.cmd("copen")
end
local function _3_()
  return vim.cmd("cclose")
end
local function _4_()
  return (vim.fn.getqflist({winid = 0}).winid ~= 0)
end
M.register("qf", {open = with_keep_window(_2_), close = _3_, is_open = _4_})
do
  local st = {}
  local open_idx
  local function _5_(idx)
    local _7_
    do
      local _6_ = st[idx]
      if (nil ~= _6_) then
        local term = _6_
        _7_ = term
      else
        local _ = _6_
        local term = require("toggleterm.terminal").Terminal:new({direction = "float"})
        st[idx] = term
        _7_ = term
      end
    end
    return _7_:open()
  end
  open_idx = _5_
  local is_open_idx
  local function _12_(idx)
    local term = st[idx]
    return (term and term:is_open())
  end
  is_open_idx = _12_
  local close_idx
  local function _13_(idx)
    local term = st[idx]
    if (term and term:is_open()) then
      return term:close()
    else
      return nil
    end
  end
  close_idx = _13_
  for i = 0, 9 do
    local function _15_()
      return open_idx(i)
    end
    local function _16_()
      return close_idx(i)
    end
    local function _17_()
      return is_open_idx(i)
    end
    M.register(("term" .. i), {open = _15_, close = _16_, is_open = _17_})
    local function _18_()
      st[i] = nil
      return nil
    end
    vim.api.nvim_create_user_command(("ClearTerm" .. i), _18_, {})
  end
end
local st = {recent_type = nil}
local mk_open
local function _19_(opt, type)
  local function _20_()
    require("trouble").open(opt)
    st["recent_type"] = type
    return nil
  end
  return with_keep_window(_20_)
end
mk_open = _19_
local close
local function _21_()
  local _22_ = package.loaded.trouble
  if (nil ~= _22_) then
    local t = _22_
    return t.close()
  else
    return nil
  end
end
close = _21_
local mk_is_open
local function _24_(type)
  local function _25_()
    local _26_ = package.loaded.trouble
    if (nil ~= _26_) then
      local t = _26_
      return (t.is_open() and (st.recent_type == type))
    else
      local _ = _26_
      return false
    end
  end
  return _25_
end
mk_is_open = _24_
M.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
return M.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
