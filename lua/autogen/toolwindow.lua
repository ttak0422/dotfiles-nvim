-- [nfnl] Compiled from fnl/toolwindow.fnl by https://github.com/Olical/nfnl, do not edit.
local W = require("toolwindow")
local Terminal = require("toggleterm.terminal").Terminal
local term_table = {}
local term_open
local function _1_(_plugin, args)
  local tmp_9_auto
  do
    local val = term_table[args.idx]
    if (val == nil) then
      local term = Terminal:new({direction = "horizontal"})
      term_table[args.idx] = term
      tmp_9_auto = term
    else
      tmp_9_auto = term_table[args.idx]
    end
  end
  tmp_9_auto:open()
  return tmp_9_auto
end
term_open = _1_
local term_close
local function _3_(plugin)
  if ((plugin ~= nil) and (plugin.is_open ~= nil) and plugin:is_open()) then
    return plugin:close()
  else
    return nil
  end
end
term_close = _3_
local qf_open
local function _5_()
  local pos = vim.api.nvim_win_get_cursor(0)
  local view = vim.fn.winsaveview()
  vim.cmd("copen")
  vim.cmd("wincmd p")
  vim.api.nvim_win_set_cursor(0, pos)
  return vim.fn.winrestview(view)
end
qf_open = _5_
local qf_close
local function _6_()
  return vim.cmd("cclose")
end
qf_close = _6_
W.register("terminal", nil, term_close, term_open)
return W.register("qf", nil, qf_close, qf_open)
