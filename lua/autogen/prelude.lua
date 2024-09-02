-- [nfnl] Compiled from fnl/prelude.fnl by https://github.com/Olical/nfnl, do not edit.
vim.loader.enable()
for k, v in pairs({langmenu = "none", shortmess = (vim.o.shortmess .. "sWcCS"), cmdheight = 0, termguicolors = true, signcolumn = "no", showtabline = 0, laststatus = 0, foldlevel = 99, foldlevelstart = 99, timeoutlen = 10000, number = false, showmode = false}) do
  vim.o[k] = v
end
vim.g.mapleader = " "
vim.g.maplocalleader = ","
do
  local M = vim.keymap.set
  local C
  local function _1_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  C = _1_
  local O = {noremap = true, silent = true}
  for _, K in ipairs({{"n", "<leader>", ":lua vim.cmd('doautocmd User TriggerLeader')<CR>", {nowait = true}}, {{"n", "v"}, ";", ":"}}) do
    M(K[1], K[2], K[3], O)
  end
  for i = 0, 9 do
    M({"n", "t", "i"}, ("<C-" .. i .. ">"), C(("TermToggle " .. i)), O)
  end
end
vim.cmd("colorscheme morimo")
return require("config-local").setup({silent = true})
