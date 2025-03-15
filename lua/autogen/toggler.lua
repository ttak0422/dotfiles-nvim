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
  local float_opts
  local function _23_()
    return math.floor((vim.o.lines * 0.9))
  end
  local function _24_()
    return math.floor((vim.o.columns * 0.9))
  end
  float_opts = {height = _23_, width = _24_}
  local open
  local function _25_()
    local _27_
    do
      local _26_ = st.term
      if (nil ~= _26_) then
        local term = _26_
        _27_ = term
      else
        local _ = _26_
        local term = require("toggleterm.terminal").Terminal:new({direction = "float", cmd = "gitu", on_create = on_create, float_opts = float_opts, shade_terminals = false})
        st["term"] = term
        _27_ = term
      end
    end
    _27_:open()
    return vim.cmd("startinsert")
  end
  open = _25_
  M.register("gitu", {open = open, close = close, is_open = is_open})
  local function _32_()
    st["term"] = nil
    return nil
  end
  create_command("ClearGitu", _32_, {})
end
do
  local st = {recent_type = nil}
  local mk_open
  local function _33_(opt, type)
    local function _34_()
      require("trouble").open(opt)
      st["recent_type"] = type
      return nil
    end
    return with_keep_window(_34_)
  end
  mk_open = _33_
  local close
  local function _35_()
    local _36_ = package.loaded.trouble
    if (nil ~= _36_) then
      local t = _36_
      return t.close()
    else
      return nil
    end
  end
  close = _35_
  local mk_is_open
  local function _38_(type)
    local function _39_()
      local _40_ = package.loaded.trouble
      if (nil ~= _40_) then
        local t = _40_
        return (t.is_open() and (st.recent_type == type))
      else
        local _ = _40_
        return false
      end
    end
    return _39_
  end
  mk_is_open = _38_
  M.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
  M.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
end
do
  local signs = require("gitsigns")
  local open
  local function _42_()
    signs.blame()
    local function _43_()
      return vim.cmd("wincmd w")
    end
    return vim.defer_fn(_43_, 100)
  end
  open = _42_
  local close
  local function _44_()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if (vim.api.nvim_win_is_valid(win) and (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "gitsigns-blame")) then
        vim.api.nvim_win_close(win, true)
      else
      end
    end
    return nil
  end
  close = _44_
  local is_open
  local function _46_()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "gitsigns-blame") then
        return true
      else
      end
    end
    return false
  end
  is_open = _46_
  M.register("blame", {open = open, close = close, is_open = is_open})
end
local dapui = nil
local open
local function _48_()
  if (dapui == nil) then
    dapui = require("dapui")
  else
  end
  return dapui:open({reset = true})
end
open = _48_
local close
local function _50_()
  if (dapui ~= nil) then
    return dapui.close()
  else
    return nil
  end
end
close = _50_
local is_open
local function _52_()
  for _, win in ipairs(require("dapui.windows").layouts) do
    if win:is_open() then
      return true
    else
    end
  end
  return false
end
is_open = _52_
return M.register("dapui", {open = open, close = close, is_open = is_open})
