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
local gitu = nil
local gitu_dir = nil
do
  local is_open
  local function _20_()
    if (nil ~= gitu) then
      return gitu:is_open()
    else
      return nil
    end
  end
  is_open = _20_
  local close
  local function _22_()
    if (nil ~= gitu) then
      return gitu:close()
    else
      return nil
    end
  end
  close = _22_
  local on_create
  local function _24_(term)
    map("t", "<ESC>", "i<ESC>", {buffer = term.bufnr, noremap = true, silent = true})
    return vim.api.nvim_create_autocmd("BufLeave", {buffer = term.bufnr, callback = close})
  end
  on_create = _24_
  local float_opts
  local function _25_()
    return math.floor((vim.o.lines * 0.9))
  end
  local function _26_()
    return math.floor((vim.o.columns * 0.9))
  end
  float_opts = {height = _25_, width = _26_}
  local open
  local function _27_()
    if (gitu_dir == nil) then
      gitu_dir = vim.fn.getcwd()
    else
      local cwd = vim.fn.getcwd()
      if (gitu_dir ~= cwd) then
        gitu_dir = cwd
        gitu = nil
      else
      end
    end
    if (gitu == nil) then
      gitu = require("toggleterm.terminal").Terminal:new({direction = "float", cmd = "gitu", on_create = on_create, float_opts = float_opts, shade_terminals = false})
    else
    end
    gitu:open()
    return vim.cmd("startinsert")
  end
  open = _27_
  M.register("gitu", {open = open, close = close, is_open = is_open})
  local function _31_()
    gitu = nil
    return nil
  end
  create_command("ClearGitu", _31_, {})
end
do
  local st = {recent_type = nil}
  local mk_open
  local function _32_(opt, type)
    local function _33_()
      require("trouble").open(opt)
      st["recent_type"] = type
      return nil
    end
    return with_keep_window(_33_)
  end
  mk_open = _32_
  local close
  local function _34_()
    local _35_ = package.loaded.trouble
    if (nil ~= _35_) then
      local t = _35_
      return t.close()
    else
      return nil
    end
  end
  close = _34_
  local mk_is_open
  local function _37_(type)
    local function _38_()
      local _39_ = package.loaded.trouble
      if (nil ~= _39_) then
        local t = _39_
        return (t.is_open() and (st.recent_type == type))
      else
        local _ = _39_
        return false
      end
    end
    return _38_
  end
  mk_is_open = _37_
  M.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
  M.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
end
do
  local signs = require("gitsigns")
  local open
  local function _41_()
    signs.blame()
    local function _42_()
      return vim.cmd("wincmd w")
    end
    return vim.defer_fn(_42_, 100)
  end
  open = _41_
  local close
  local function _43_()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if (vim.api.nvim_win_is_valid(win) and (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "gitsigns-blame")) then
        vim.api.nvim_win_close(win, true)
      else
      end
    end
    return nil
  end
  close = _43_
  local is_open
  local function _45_()
    return filetype_exists("gitsigns-blame")
  end
  is_open = _45_
  M.register("blame", {open = open, close = close, is_open = is_open})
end
local dapui = nil
do
  local open
  local function _46_()
    if (dapui == nil) then
      dapui = require("dapui")
    else
    end
    return dapui:open({reset = true})
  end
  open = _46_
  local close
  local function _48_()
    if (dapui ~= nil) then
      return dapui.close()
    else
      return nil
    end
  end
  close = _48_
  local is_open
  local function _50_()
    for _, win in ipairs(require("dapui.windows").layouts) do
      if win:is_open() then
        return true
      else
      end
    end
    return false
  end
  is_open = _50_
  M.register("dapui", {open = open, close = close, is_open = is_open})
end
local neotest = nil
do
  local open
  local function _52_()
    if (neotest == nil) then
      neotest = require("neotest")
    else
    end
    return neotest.output_panel.open()
  end
  open = _52_
  local close
  local function _54_()
    if (neotest ~= nil) then
      return neotest.output_panel.close()
    else
      return nil
    end
  end
  close = _54_
  local is_open
  local function _56_()
    return filetype_exists("neotest-output-panel")
  end
  is_open = _56_
  M.register("neotest-output", {open = open, close = close, is_open = is_open})
end
do
  local open
  local function _57_()
    if (neotest == nil) then
      neotest = require("neotest")
      return nil
    else
      return neotest.summary.open()
    end
  end
  open = _57_
  local close
  local function _59_()
    if (neotest ~= nil) then
      return neotest.summary.close()
    else
      return nil
    end
  end
  close = _59_
  local is_open
  local function _61_()
    return filetype_exists("neotest-summary")
  end
  is_open = _61_
  M.register("neotest-summary", {open = open, close = close, is_open = is_open})
end
local aerial = nil
local open
local function _62_()
  if (aerial == nil) then
    aerial = require("aerial")
  else
  end
  return aerial.open()
end
open = _62_
local close
local function _64_()
  if (aerial ~= nil) then
    return aerial.close()
  else
    return nil
  end
end
close = _64_
local is_open
local function _66_()
  return filetype_exists("aerial")
end
is_open = _66_
return M.register("aerial", {open = open, close = close, is_open = is_open})
