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
local function filetype_exists(ft)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == ft) then
      return true
    else
    end
  end
  return false
end
local function _3_()
  return vim.cmd("copen")
end
local function _4_()
  return vim.cmd("cclose")
end
local function _5_()
  return (vim.fn.getqflist({winid = 0}).winid ~= 0)
end
M.register("qf", {open = with_keep_window(_3_), close = _4_, is_open = _5_})
do
  local st = {}
  local open_idx
  local function _6_(idx)
    local _8_
    do
      local _7_ = st[idx]
      if (nil ~= _7_) then
        local term = _7_
        _8_ = term
      else
        local _ = _7_
        local term = require("toggleterm.terminal").Terminal:new({direction = "float"})
        st[idx] = term
        _8_ = term
      end
    end
    return _8_:open()
  end
  open_idx = _6_
  local is_open_idx
  local function _13_(idx)
    local term = st[idx]
    return (term and term:is_open())
  end
  is_open_idx = _13_
  local close_idx
  local function _14_(idx)
    local term = st[idx]
    if (term and term:is_open()) then
      return term:close()
    else
      return nil
    end
  end
  close_idx = _14_
  for i = 0, 9 do
    local function _16_()
      return open_idx(i)
    end
    local function _17_()
      return close_idx(i)
    end
    local function _18_()
      return is_open_idx(i)
    end
    M.register(("term" .. i), {open = _16_, close = _17_, is_open = _18_})
    local function _19_()
      st[i] = nil
      return nil
    end
    create_command(("ClearTerm" .. i), _19_, {})
  end
end
do
  local st = {term = nil}
  local is_open
  local function _20_()
    local term = st.term
    return (term and term:is_open())
  end
  is_open = _20_
  local close
  local function _21_()
    local term = st.term
    if (term and term:is_open()) then
      return term:close()
    else
      return nil
    end
  end
  close = _21_
  local on_create
  local function _23_(term)
    map("t", "<ESC>", "i<ESC>", {buffer = term.bufnr, noremap = true, silent = true})
    return vim.api.nvim_create_autocmd("BufLeave", {buffer = term.bufnr, callback = close})
  end
  on_create = _23_
  local float_opts
  local function _24_()
    return math.floor((vim.o.lines * 0.9))
  end
  local function _25_()
    return math.floor((vim.o.columns * 0.9))
  end
  float_opts = {height = _24_, width = _25_}
  local open
  local function _26_()
    local _28_
    do
      local _27_ = st.term
      if (nil ~= _27_) then
        local term = _27_
        _28_ = term
      else
        local _ = _27_
        local term = require("toggleterm.terminal").Terminal:new({direction = "float", cmd = "gitu", on_create = on_create, float_opts = float_opts, shade_terminals = false})
        st["term"] = term
        _28_ = term
      end
    end
    _28_:open()
    return vim.cmd("startinsert")
  end
  open = _26_
  M.register("gitu", {open = open, close = close, is_open = is_open})
  local function _33_()
    st["term"] = nil
    return nil
  end
  create_command("ClearGitu", _33_, {})
end
do
  local st = {recent_type = nil}
  local mk_open
  local function _34_(opt, type)
    local function _35_()
      require("trouble").open(opt)
      st["recent_type"] = type
      return nil
    end
    return with_keep_window(_35_)
  end
  mk_open = _34_
  local close
  local function _36_()
    local _37_ = package.loaded.trouble
    if (nil ~= _37_) then
      local t = _37_
      return t.close()
    else
      return nil
    end
  end
  close = _36_
  local mk_is_open
  local function _39_(type)
    local function _40_()
      local _41_ = package.loaded.trouble
      if (nil ~= _41_) then
        local t = _41_
        return (t.is_open() and (st.recent_type == type))
      else
        local _ = _41_
        return false
      end
    end
    return _40_
  end
  mk_is_open = _39_
  M.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
  M.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
end
do
  local signs = require("gitsigns")
  local open
  local function _43_()
    signs.blame()
    local function _44_()
      return vim.cmd("wincmd w")
    end
    return vim.defer_fn(_44_, 100)
  end
  open = _43_
  local close
  local function _45_()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if (vim.api.nvim_win_is_valid(win) and (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "gitsigns-blame")) then
        vim.api.nvim_win_close(win, true)
      else
      end
    end
    return nil
  end
  close = _45_
  local is_open
  local function _47_()
    return filetype_exists("gitsigns-blame")
  end
  is_open = _47_
  M.register("blame", {open = open, close = close, is_open = is_open})
end
local dapui = nil
do
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
  M.register("dapui", {open = open, close = close, is_open = is_open})
end
local neotest = nil
do
  local open
  local function _54_()
    if (neotest == nil) then
      neotest = require("neotest")
    else
    end
    return neotest.output_panel.open()
  end
  open = _54_
  local close
  local function _56_()
    if (neotest ~= nil) then
      return neotest.output_panel.close()
    else
      return nil
    end
  end
  close = _56_
  local is_open
  local function _58_()
    return filetype_exists("neotest-output-panel")
  end
  is_open = _58_
  M.register("neotest-output", {open = open, close = close, is_open = is_open})
end
local open
local function _59_()
  if (neotest == nil) then
    neotest = require("neotest")
    return nil
  else
    return neotest.summary.open()
  end
end
open = _59_
local close
local function _61_()
  if (neotest ~= nil) then
    return neotest.summary.close()
  else
    return nil
  end
end
close = _61_
local is_open
local function _63_()
  return filetype_exists("neotest-summary")
end
is_open = _63_
return M.register("neotest-summary", {open = open, close = close, is_open = is_open})
