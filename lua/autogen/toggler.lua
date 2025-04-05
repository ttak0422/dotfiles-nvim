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
local function tmux_attach_or_create(session, window)
  if (vim.system({"tmux", "has-session", "-t", session}):wait().code ~= 0) then
    vim.system({"tmux", "new-session", "-d", "-s", session}):wait()
  else
  end
  if (window ~= "") then
    local windows = vim.system({"tmux", "list-windows", "-t", session}):wait().stdout:gmatch("[^\n]+")
    local exists
    do
      local acc = false
      for w, _ in windows do
        acc = (acc or (w:match(("^" .. vim.pesc(window) .. ":")) ~= nil))
      end
      exists = acc
    end
    if not exists then
      return vim.system({"tmux", "new-window", "-t", (session .. ":" .. window)}):wait()
    else
      return nil
    end
  else
    return nil
  end
end
local toggleterm = {}
do
  local open_idx
  local function _9_(idx)
    local terminal = require("toggleterm.terminal")
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local target = (cwd .. "_" .. idx)
    tmux_attach_or_create(target, "0")
    local _11_
    do
      local _10_ = toggleterm[idx]
      if (nil ~= _10_) then
        local t = _10_
        _11_ = t
      else
        local _ = _10_
        local t = terminal.Terminal:new({direction = "float", float_opts = {border = "single"}, cmd = ("tmux attach-session -t " .. target)})
        toggleterm[idx] = t
        _11_ = t
      end
    end
    return _11_:open()
  end
  open_idx = _9_
  local is_open_idx
  local function _16_(idx)
    local t = toggleterm[idx]
    return (t and t:is_open())
  end
  is_open_idx = _16_
  local close_idx
  local function _17_(idx)
    local t = toggleterm[idx]
    if (t and t:is_open()) then
      return t:close()
    else
      return nil
    end
  end
  close_idx = _17_
  for i = 0, 9 do
    local function _19_()
      return open_idx(i)
    end
    local function _20_()
      return close_idx(i)
    end
    local function _21_()
      return is_open_idx(i)
    end
    M.register(("term" .. i), {open = _19_, close = _20_, is_open = _21_})
  end
end
local gitu = nil
local gitu_dir = nil
do
  local is_open
  local function _22_()
    if (nil ~= gitu) then
      return gitu:is_open()
    else
      return nil
    end
  end
  is_open = _22_
  local close
  local function _24_()
    if (nil ~= gitu) then
      return gitu:close()
    else
      return nil
    end
  end
  close = _24_
  local on_create
  local function _26_(term)
    map("t", "<ESC>", "i<ESC>", {buffer = term.bufnr, noremap = true, silent = true})
    return vim.api.nvim_create_autocmd("BufLeave", {buffer = term.bufnr, callback = close})
  end
  on_create = _26_
  local on_open
  local function _27_()
    return vim.cmd("startinsert")
  end
  on_open = _27_
  local float_opts
  local function _28_()
    return math.floor((vim.o.lines * 0.9))
  end
  local function _29_()
    return math.floor((vim.o.columns * 0.9))
  end
  float_opts = {height = _28_, width = _29_}
  local open
  local function _30_()
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
  open = _30_
  M.register("gitu", {open = open, close = close, is_open = is_open})
  local function _34_()
    gitu = nil
    return nil
  end
  create_command("ClearGitu", _34_, {})
end
do
  local st = {recent_type = nil}
  local mk_open
  local function _35_(opt, type)
    local function _36_()
      require("trouble").open(opt)
      st["recent_type"] = type
      return nil
    end
    return with_keep_window(_36_)
  end
  mk_open = _35_
  local close
  local function _37_()
    local _38_ = package.loaded.trouble
    if (nil ~= _38_) then
      local t = _38_
      return t.close()
    else
      return nil
    end
  end
  close = _37_
  local mk_is_open
  local function _40_(type)
    local function _41_()
      local _42_ = package.loaded.trouble
      if (nil ~= _42_) then
        local t = _42_
        return (t.is_open() and (st.recent_type == type))
      else
        local _ = _42_
        return false
      end
    end
    return _41_
  end
  mk_is_open = _40_
  M.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
  M.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
end
do
  local signs = require("gitsigns")
  local open
  local function _44_()
    signs.blame()
    local function _45_()
      return vim.cmd("wincmd w")
    end
    return vim.defer_fn(_45_, 100)
  end
  open = _44_
  local close
  local function _46_()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if (vim.api.nvim_win_is_valid(win) and (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "gitsigns-blame")) then
        vim.api.nvim_win_close(win, true)
      else
      end
    end
    return nil
  end
  close = _46_
  local is_open
  local function _48_()
    return filetype_exists("gitsigns-blame")
  end
  is_open = _48_
  M.register("blame", {open = open, close = close, is_open = is_open})
end
local dapui = nil
do
  local open
  local function _49_()
    if (dapui == nil) then
      dapui = require("dapui")
    else
    end
    return dapui:open({reset = true})
  end
  open = _49_
  local close
  local function _51_()
    if (dapui ~= nil) then
      return dapui.close()
    else
      return nil
    end
  end
  close = _51_
  local is_open
  local function _53_()
    for _, win in ipairs(require("dapui.windows").layouts) do
      if win:is_open() then
        return true
      else
      end
    end
    return false
  end
  is_open = _53_
  M.register("dapui", {open = open, close = close, is_open = is_open})
end
local neotest = nil
do
  local open
  local function _55_()
    if (neotest == nil) then
      neotest = require("neotest")
    else
    end
    return neotest.output_panel.open()
  end
  open = _55_
  local close
  local function _57_()
    if (neotest ~= nil) then
      return neotest.output_panel.close()
    else
      return nil
    end
  end
  close = _57_
  local is_open
  local function _59_()
    return filetype_exists("neotest-output-panel")
  end
  is_open = _59_
  M.register("neotest-output", {open = open, close = close, is_open = is_open})
end
do
  local open
  local function _60_()
    if (neotest == nil) then
      neotest = require("neotest")
      return nil
    else
      return neotest.summary.open()
    end
  end
  open = _60_
  local close
  local function _62_()
    if (neotest ~= nil) then
      return neotest.summary.close()
    else
      return nil
    end
  end
  close = _62_
  local is_open
  local function _64_()
    return filetype_exists("neotest-summary")
  end
  is_open = _64_
  M.register("neotest-summary", {open = open, close = close, is_open = is_open})
end
local aerial = nil
local open
local function _65_()
  if (aerial == nil) then
    aerial = require("aerial")
  else
  end
  return aerial.open()
end
open = _65_
local close
local function _67_()
  if (aerial ~= nil) then
    return aerial.close()
  else
    return nil
  end
end
close = _67_
local is_open
local function _69_()
  return filetype_exists("aerial")
end
is_open = _69_
return M.register("aerial", {open = open, close = close, is_open = is_open})
