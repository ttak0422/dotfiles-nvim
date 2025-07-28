-- [nfnl] v2/fnl/toggle-plugins.fnl
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
do
  local st = {recent_type = nil}
  local mk_open
  local function _15_(opt, type)
    local function _16_()
      require("trouble").open(opt)
      st["recent_type"] = type
      return nil
    end
    return with_keep_window(_16_)
  end
  mk_open = _15_
  local close
  local function _17_()
    local _18_ = package.loaded.trouble
    if (nil ~= _18_) then
      local t = _18_
      return t.close()
    else
      return nil
    end
  end
  close = _17_
  local mk_is_open
  local function _20_(type)
    local function _21_()
      local _22_ = package.loaded.trouble
      if (nil ~= _22_) then
        local t = _22_
        return (t.is_open() and (st.recent_type == type))
      else
        local _ = _22_
        return false
      end
    end
    return _21_
  end
  mk_is_open = _20_
  toggler.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
  toggler.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
end
local tmux = args.tmux_path
local function tmux_attach_or_create(session, window)
  if (vim.system({tmux, "has-session", "-t", session}):wait().code ~= 0) then
    vim.system({tmux, "new-session", "-d", "-s", session}):wait()
  else
  end
  if (window ~= "") then
    local windows = vim.system({tmux, "list-windows", "-t", session}):wait().stdout:gmatch("[^\n]+")
    local exists
    do
      local acc = false
      for w, _ in windows do
        acc = (acc or (w:match(("^" .. vim.pesc(window) .. ":")) ~= nil))
      end
      exists = acc
    end
    if not exists then
      return vim.system({tmux, "new-window", "-t", (session .. ":" .. window)}):wait()
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
  local function _27_(idx)
    local terminal = require("toggleterm.terminal")
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local target = (string.gsub(cwd, "%.", "_") .. "_" .. idx)
    tmux_attach_or_create(target, "0")
    local or_28_ = toggleterm[idx]
    if not or_28_ then
      local t = terminal.Terminal:new({direction = "horizontal", float_opts = {border = "single"}, cmd = ("tmux attach-session -t " .. target)})
      toggleterm[idx] = t
      or_28_ = t
    end
    return (or_28_):open()
  end
  open_idx = _27_
  local is_open_idx
  local function _30_(idx)
    local t = toggleterm[idx]
    return (t and t:is_open())
  end
  is_open_idx = _30_
  local close_idx
  local function _31_(idx)
    local t = toggleterm[idx]
    if (t and t:is_open()) then
      return t:close()
    else
      return nil
    end
  end
  close_idx = _31_
  for i = 0, 9 do
    local function _33_()
      return open_idx(i)
    end
    local function _34_()
      return close_idx(i)
    end
    local function _35_()
      return is_open_idx(i)
    end
    toggler.register(("term" .. i), {open = _33_, close = _34_, is_open = _35_})
  end
end
local dapui = nil
do
  local open
  local function _36_()
    if (dapui == nil) then
      dapui = require("dapui")
    else
    end
    return dapui:open({reset = true})
  end
  open = _36_
  local close
  local function _38_()
    if (dapui ~= nil) then
      return dapui.close()
    else
      return nil
    end
  end
  close = _38_
  local is_open
  local function _40_()
    for _, win in ipairs(require("dapui.windows").layouts) do
      if win:is_open() then
        return true
      else
      end
    end
    return false
  end
  is_open = _40_
  toggler.register("dapui", {open = open, close = close, is_open = is_open})
end
local aerial = nil
local open
local function _42_()
  if (aerial == nil) then
    aerial = require("aerial")
  else
  end
  return aerial.open()
end
open = _42_
local close
local function _44_()
  if (aerial ~= nil) then
    return aerial.close()
  else
    return nil
  end
end
close = _44_
local is_open
local function _46_()
  return filetype_exists("aerial")
end
is_open = _46_
return toggler.register("aerial", {open = open, close = close, is_open = is_open})
