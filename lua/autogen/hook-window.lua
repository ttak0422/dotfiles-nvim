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
local function _3_()
  return require("nvim-window").pick()
end
for _, k in ipairs({{"<C-w>H", cmd("WinShift left")}, {"<C-w>J", cmd("WinShift down")}, {"<C-w>K", cmd("WinShift up")}, {"<C-w>L", cmd("WinShift right")}, {"<C-w>p", _3_, desc("pick window")}, {"<C-w><CR>", cmd("DetourCurrentWindow")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
