-- [nfnl] Compiled from v2/fnl/toggle-plugins.fnl by https://github.com/Olical/nfnl, do not edit.
local toggler = require("toggler")
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
toggler.register("qf", {open = with_keep_window(_2_), close = _3_, is_open = _4_})
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
local open_idx
local function _8_(idx)
  local terminal = require("toggleterm.terminal")
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local target = (cwd .. "_" .. idx)
  tmux_attach_or_create(target, "0")
  local or_9_ = toggleterm[idx]
  if not or_9_ then
    local t = terminal.Terminal:new({direction = "float", float_opts = {border = "single"}, cmd = ("tmux attach-session -t " .. target)})
    toggleterm[idx] = t
    or_9_ = t
  end
  return (or_9_):open()
end
open_idx = _8_
local is_open_idx
local function _11_(idx)
  local t = toggleterm[idx]
  return (t and t:is_open())
end
is_open_idx = _11_
local close_idx
local function _12_(idx)
  local t = toggleterm[idx]
  if (t and t:is_open()) then
    return t:close()
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
  toggler.register(("term" .. i), {open = _14_, close = _15_, is_open = _16_})
end
return nil
