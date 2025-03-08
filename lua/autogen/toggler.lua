-- [nfnl] Compiled from fnl/toggler.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("toggler")
local map = vim.keymap.set
local create_command = vim.api.nvim_create_user_command
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
    create_command(("ClearTerm" .. i), _18_, {})
  end
end
do
  local st = {term = nil}
  local is_open
  local function _19_()
    local term = st.term
    return (term and term:is_open())
  end
  is_open = _19_
  local close
  local function _20_()
    local term = st.term
    if (term and term:is_open()) then
      return term:close()
    else
      return nil
    end
  end
  close = _20_
  local on_create
  local function _22_(term)
    map("t", "<ESC>", "i<ESC>", {buffer = term.bufnr, noremap = true, silent = true})
    return vim.api.nvim_create_autocmd("BufLeave", {buffer = term.bufnr, callback = close})
  end
  on_create = _22_
  local open
  local function _23_()
    local _25_
    do
      local _24_ = st.term
      if (nil ~= _24_) then
        local term = _24_
        _25_ = term
      else
        local _ = _24_
        local term = require("toggleterm.terminal").Terminal:new({cmd = "gitu", hidden = true, on_create = on_create})
        st["term"] = term
        _25_ = term
      end
    end
    _25_:open()
    return vim.cmd("startinsert")
  end
  open = _23_
  M.register("gitu", {open = open, close = close, is_open = is_open})
  local function _30_()
    st["term"] = nil
    return nil
  end
  create_command("ClearGitu", _30_, {})
end
do
  local st = {recent_type = nil}
  local mk_open
  local function _31_(opt, type)
    local function _32_()
      require("trouble").open(opt)
      st["recent_type"] = type
      return nil
    end
    return with_keep_window(_32_)
  end
  mk_open = _31_
  local close
  local function _33_()
    local _34_ = package.loaded.trouble
    if (nil ~= _34_) then
      local t = _34_
      return t.close()
    else
      return nil
    end
  end
  close = _33_
  local mk_is_open
  local function _36_(type)
    local function _37_()
      local _38_ = package.loaded.trouble
      if (nil ~= _38_) then
        local t = _38_
        return (t.is_open() and (st.recent_type == type))
      else
        local _ = _38_
        return false
      end
    end
    return _37_
  end
  mk_is_open = _36_
  M.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
  M.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
end
local signs = require("gitsigns")
local open
local function _40_()
  signs.blame()
  local function _41_()
    return vim.cmd("wincmd w")
  end
  return vim.defer_fn(_41_, 100)
end
open = _40_
local close
local function _42_()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if (vim.api.nvim_win_is_valid(win) and (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "gitsigns-blame")) then
      vim.api.nvim_win_close(win, true)
    else
    end
  end
  return nil
end
close = _42_
local is_open
local function _44_()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "gitsigns-blame") then
      return true
    else
    end
  end
  return false
end
is_open = _44_
return M.register("blame", {open = open, close = close, is_open = is_open})
