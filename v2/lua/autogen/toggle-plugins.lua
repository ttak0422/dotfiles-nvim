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
    return vim.system({tmux, "new-session", "-d", "-s", session, "-n", window}):wait()
  else
    return nil
  end
end
local toggleterm = {}
do
  local open_idx
  local function _25_(idx)
    local terminal = require("toggleterm.terminal")
    local session = ("vim_" .. idx)
    local window = "default"
    local copy_with
    local function _26_(cmd)
      for _, cs in ipairs({{tmux, "copy-mode", "-t", session}, {tmux, "send", "-X", "-t", session, cmd}}) do
        vim.system(cs):wait()
      end
      return nil
    end
    copy_with = _26_
    local copy_with_send
    local function _27_(key)
      for _, cs in ipairs({{tmux, "copy-mode", "-t", session}, {tmux, "send", "-t", session, key}}) do
        vim.system(cs):wait()
      end
      return nil
    end
    copy_with_send = _27_
    local on_open
    local function _28_(term)
      local function _29_()
        return copy_with("page-down")
      end
      local function _30_()
        return copy_with("page-up")
      end
      local function _31_()
        return copy_with("halfpage-down")
      end
      local function _32_()
        return copy_with("halfpage-up")
      end
      local function _33_()
        return copy_with_send("g")
      end
      local function _34_()
        return copy_with_send("G")
      end
      for k, v in pairs({["<C-f>"] = _29_, ["<C-b>"] = _30_, ["<C-d>"] = _31_, ["<C-u>"] = _32_, gg = _33_, G = _34_}) do
        vim.keymap.set("n", k, v, {buffer = term.bufnr, noremap = true, silent = true})
      end
      return nil
    end
    on_open = _28_
    tmux_attach_or_create(session, window)
    local or_35_ = toggleterm[idx]
    if not or_35_ then
      local t = terminal.Terminal:new({cmd = (tmux .. " attach-session -t " .. session), on_open = on_open})
      toggleterm[idx] = t
      or_35_ = t
    end
    return (or_35_):open()
  end
  open_idx = _25_
  local is_open_idx
  local function _37_(idx)
    local t = toggleterm[idx]
    return (t and t:is_open())
  end
  is_open_idx = _37_
  local close_idx
  local function _38_(idx)
    local t = toggleterm[idx]
    if (t and t:is_open()) then
      return t:close()
    else
      return nil
    end
  end
  close_idx = _38_
  for i = 0, 9 do
    local function _40_()
      return open_idx(i)
    end
    local function _41_()
      return close_idx(i)
    end
    local function _42_()
      return is_open_idx(i)
    end
    toggler.register(("term" .. i), {open = _40_, close = _41_, is_open = _42_})
  end
end
local dapui = nil
do
  local open
  local function _43_()
    if (dapui == nil) then
      dapui = require("dapui")
    else
    end
    return dapui:open({reset = true})
  end
  open = _43_
  local close
  local function _45_()
    if (dapui ~= nil) then
      return dapui.close()
    else
      return nil
    end
  end
  close = _45_
  local is_open
  local function _47_()
    for _, win in ipairs(require("dapui.windows").layouts) do
      if win:is_open() then
        return true
      else
      end
    end
    return false
  end
  is_open = _47_
  toggler.register("dapui", {open = open, close = close, is_open = is_open})
end
local aerial = nil
local open
local function _49_()
  if (aerial == nil) then
    aerial = require("aerial")
  else
  end
  return aerial.open()
end
open = _49_
local close
local function _51_()
  if (aerial ~= nil) then
    return aerial.close()
  else
    return nil
  end
end
close = _51_
local is_open
local function _53_()
  return filetype_exists("aerial")
end
is_open = _53_
return toggler.register("aerial", {open = open, close = close, is_open = is_open})
