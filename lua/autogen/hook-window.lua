-- [nfnl] Compiled from fnl/hook-window.fnl by https://github.com/Olical/nfnl, do not edit.
local opts = {noremap = true, silent = true}
local cmd
local function _1_(c)
  return ("<cmd>" .. c .. "<cr>")
end
cmd = _1_
local desc
local function _2_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _2_
local N
local function _3_()
  return (require("smart-splits")).start_resize_mode()
end
local function _4_()
  return (require("nvim-window")).pick()
end
N = {{"<C-w>H", cmd("WinShift left")}, {"<C-w>J", cmd("WinShift down")}, {"<C-w>K", cmd("WinShift up")}, {"<C-w>L", cmd("WinShift right")}, {"<C-w>e", _3_, desc("resize mode")}, {"<C-w>p", _4_, desc("pick window")}, {"<C-w><CR>", cmd("DetourCurrentWindow")}}
for _, k in ipairs(N) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
