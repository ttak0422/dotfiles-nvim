-- [nfnl] Compiled from v2/fnl/toggle-plugins.fnl by https://github.com/Olical/nfnl, do not edit.
local toggler = require("toggler")
local function with_keep_window(f)
  local function _1_()
    local win = vim.api.nvim_get_current_win()
    f()
    if vim.api.nvim_win_is_valid(win) then
      return vim.api.nvim_set_current_win(win)
    else
      return nil
    end
  end
  return _1_
end
local function filetype_exists(ft)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if (vim.api.nvim_win_is_valid(win) and (vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == ft)) then
      return true
    else
    end
  end
  return false
end
local qf_3f = false
local function _4_()
  if not qf_3f then
    vim.cmd("copen")
    qf_3f = true
    return nil
  else
    return nil
  end
end
local function _6_()
  if qf_3f then
    vim.cmd("cclose")
    qf_3f = false
    return nil
  else
    return nil
  end
end
local function _8_()
  local is_open = filetype_exists("qf")
  qf_3f = is_open
  return is_open
end
toggler.register("qf", {open = with_keep_window(_4_), close = _6_, is_open = _8_})
local harpoon_3f = false
do
  local toggle
  local function _9_()
    local h = require("harpoon")
    return h.ui:toggle_quick_menu(h:list(), {border = "none"})
  end
  toggle = _9_
  local function _10_()
    if not harpoon_3f then
      return toggle()
    else
      return nil
    end
  end
  local function _12_()
    if harpoon_3f then
      return toggle()
    else
      return nil
    end
  end
  local function _14_()
    local is_open = filetype_exists("harpoon")
    harpoon_3f = is_open
    return is_open
  end
  toggler.register("harpoon", {open = _10_, close = _12_, is_open = _14_})
end
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
local function _18_(idx)
  local terminal = require("toggleterm.terminal")
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local target = (cwd .. "_" .. idx)
  tmux_attach_or_create(target, "0")
  local or_19_ = toggleterm[idx]
  if not or_19_ then
    local t = terminal.Terminal:new({direction = "float", float_opts = {border = "single"}, cmd = ("tmux attach-session -t " .. target)})
    toggleterm[idx] = t
    or_19_ = t
  end
  return (or_19_):open()
end
open_idx = _18_
local is_open_idx
local function _21_(idx)
  local t = toggleterm[idx]
  return (t and t:is_open())
end
is_open_idx = _21_
local close_idx
local function _22_(idx)
  local t = toggleterm[idx]
  if (t and t:is_open()) then
    return t:close()
  else
    return nil
  end
end
close_idx = _22_
for i = 0, 9 do
  local function _24_()
    return open_idx(i)
  end
  local function _25_()
    return close_idx(i)
  end
  local function _26_()
    return is_open_idx(i)
  end
  toggler.register(("term" .. i), {open = _24_, close = _25_, is_open = _26_})
end
return nil
