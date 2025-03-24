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
        local session = ("VIM" .. idx)
        local term = require("toggleterm.terminal").Terminal:new({direction = "float", float_opts = {border = "none"}, cmd = ("zellij attach " .. session .. " --create")})
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
  local on_open
  local function _25_()
    return vim.cmd("startinsert")
  end
  on_open = _25_
  local float_opts
  local function _26_()
    return math.floor((vim.o.lines * 0.9))
  end
  local function _27_()
    return math.floor((vim.o.columns * 0.9))
  end
  float_opts = {height = _26_, width = _27_}
  local open
  local function _28_()
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
      gitu = require("toggleterm.terminal").Terminal:new({direction = "float", cmd = "gitu", on_create = on_create, on_open = on_open, float_opts = float_opts, shade_terminals = false})
    else
    end
    return gitu:open()
  end
  open = _28_
  M.register("gitu", {open = open, close = close, is_open = is_open})
  local function _32_()
    gitu = nil
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
    return filetype_exists("gitsigns-blame")
  end
  is_open = _46_
  M.register("blame", {open = open, close = close, is_open = is_open})
end
local dapui = nil
do
  local open
  local function _47_()
    if (dapui == nil) then
      dapui = require("dapui")
    else
    end
    return dapui:open({reset = true})
  end
  open = _47_
  local close
  local function _49_()
    if (dapui ~= nil) then
      return dapui.close()
    else
      return nil
    end
  end
  close = _49_
  local is_open
  local function _51_()
    for _, win in ipairs(require("dapui.windows").layouts) do
      if win:is_open() then
        return true
      else
      end
    end
    return false
  end
  is_open = _51_
  M.register("dapui", {open = open, close = close, is_open = is_open})
end
local neotest = nil
do
  local open
  local function _53_()
    if (neotest == nil) then
      neotest = require("neotest")
    else
    end
    return neotest.output_panel.open()
  end
  open = _53_
  local close
  local function _55_()
    if (neotest ~= nil) then
      return neotest.output_panel.close()
    else
      return nil
    end
  end
  close = _55_
  local is_open
  local function _57_()
    return filetype_exists("neotest-output-panel")
  end
  is_open = _57_
  M.register("neotest-output", {open = open, close = close, is_open = is_open})
end
do
  local open
  local function _58_()
    if (neotest == nil) then
      neotest = require("neotest")
      return nil
    else
      return neotest.summary.open()
    end
  end
  open = _58_
  local close
  local function _60_()
    if (neotest ~= nil) then
      return neotest.summary.close()
    else
      return nil
    end
  end
  close = _60_
  local is_open
  local function _62_()
    return filetype_exists("neotest-summary")
  end
  is_open = _62_
  M.register("neotest-summary", {open = open, close = close, is_open = is_open})
end
local aerial = nil
local open
local function _63_()
  if (aerial == nil) then
    aerial = require("aerial")
  else
  end
  return aerial.open()
end
open = _63_
local close
local function _65_()
  if (aerial ~= nil) then
    return aerial.close()
  else
    return nil
  end
end
close = _65_
local is_open
local function _67_()
  return filetype_exists("aerial")
end
is_open = _67_
return M.register("aerial", {open = open, close = close, is_open = is_open})
