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
    if (vim.api.nvim_win_is_valid(win) and (vim.api.nvim_get_option_value("filetype", {buf = vim.api.nvim_win_get_buf(win)}) == ft)) then
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
    return h.ui:toggle_quick_menu(h:list(), {title = "", border = "single"})
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
    local case_18_ = package.loaded.trouble
    if (nil ~= case_18_) then
      local t = case_18_
      return t.close()
    else
      return nil
    end
  end
  close = _17_
  local mk_is_open
  local function _20_(type)
    local function _21_()
      local case_22_ = package.loaded.trouble
      if (nil ~= case_22_) then
        local t = case_22_
        return (t.is_open() and (st.recent_type == type))
      else
        local _ = case_22_
        return false
      end
    end
    return _21_
  end
  mk_is_open = _20_
  toggler.register("trouble-doc", {open = mk_open({mode = "diagnostics", filter = {buf = 0}}, "doc"), close = close, is_open = mk_is_open("doc")})
  toggler.register("trouble-ws", {open = mk_open({mode = "diagnostics"}, "ws"), close = close, is_open = mk_is_open("ws")})
end
local toggleterm = {}
do
  local current_tab
  local function _24_()
    return vim.api.nvim_get_current_tabpage()
  end
  current_tab = _24_
  local tab_terminals
  local function _25_(tab)
    local or_26_ = toggleterm[tab]
    if not or_26_ then
      local terms = {}
      toggleterm[tab] = terms
      or_26_ = terms
    end
    return or_26_
  end
  tab_terminals = _25_
  local get_idx
  local function _28_(idx)
    local tab = current_tab()
    local terms = tab_terminals(tab)
    return terms[idx]
  end
  get_idx = _28_
  local open_idx
  local function _29_(idx)
    local terminal = require("toggleterm.terminal")
    local tab = current_tab()
    local terms = tab_terminals(tab)
    local session = ("vim_tab" .. tab .. "_idx" .. idx)
    local or_30_ = terms[idx]
    if not or_30_ then
      local t = terminal.Terminal:new({cmd = (args.pterm .. " open " .. session), close_on_exit = false})
      terms[idx] = t
      or_30_ = t
    end
    return (or_30_):open()
  end
  open_idx = _29_
  local is_open_idx
  local function _32_(idx)
    local t = get_idx(idx)
    return (t and t:is_open())
  end
  is_open_idx = _32_
  local close_idx
  local function _33_(idx)
    local t = get_idx(idx)
    if (t and t:is_open()) then
      return t:close()
    else
      return nil
    end
  end
  close_idx = _33_
  for i = 0, 9 do
    local function _35_()
      return open_idx(i)
    end
    local function _36_()
      return close_idx(i)
    end
    local function _37_()
      return is_open_idx(i)
    end
    toggler.register(("term" .. i), {open = _35_, close = _36_, is_open = _37_})
  end
end
local dapui = nil
do
  local open
  local function _38_()
    if (dapui == nil) then
      dapui = require("dapui")
    else
    end
    return dapui:open({reset = true})
  end
  open = _38_
  local close
  local function _40_()
    if (dapui ~= nil) then
      return dapui.close()
    else
      return nil
    end
  end
  close = _40_
  local is_open
  local function _42_()
    for _, win in ipairs(require("dapui.windows").layouts) do
      if win:is_open() then
        return true
      else
      end
    end
    return false
  end
  is_open = _42_
  toggler.register("dapui", {open = open, close = close, is_open = is_open})
end
local aerial = nil
local open
local function _44_()
  if (aerial == nil) then
    aerial = require("aerial")
  else
  end
  return aerial.open()
end
open = _44_
local close
local function _46_()
  if (aerial ~= nil) then
    return aerial.close()
  else
    return nil
  end
end
close = _46_
local is_open
local function _48_()
  return filetype_exists("aerial")
end
is_open = _48_
return toggler.register("aerial", {open = open, close = close, is_open = is_open})
