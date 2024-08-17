-- [nfnl] Compiled from fnl/prelude.fnl by https://github.com/Olical/nfnl, do not edit.
vim.loader.enable()
vim.cmd("language en_US")
for k, v in pairs({langmenu = "none", shortmess = (vim.o.shortmess .. "sWcCS"), cmdheight = 0, termguicolors = true, signcolumn = "no", showtabline = 0, laststatus = 0, foldlevel = 99, foldlevelstart = 99, number = false, showmode = false}) do
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
  for _, K in ipairs({{"n", "<leader>", ":lua vim.cmd('doautocmd User TriggerLeader')<CR>"}, {{"n", "v"}, ";", ":"}, {"n", "<esc><esc>", C("nohl")}, {"n", "j", "gj"}, {"n", "k", "gk"}}) do
    M(K[1], K[2], K[3], O)
  end
  for i = 0, 9 do
    M({"n", "t", "i"}, ("<C-" .. i .. ">"), C(("TermToggle " .. i)), O)
  end
end
local specificFileEnterAutoCmd = nil
do
  local A = vim.api
  local function _2_()
    local _3_
    do
      local B = vim.bo.buftype
      _3_ = not ((B == "prompt") or (B == "nofile"))
    end
    if _3_ then
      A.nvim_exec_autocmds("User", {pattern = "SpecificFileEnter"})
      return A.nvim_del_autocmd(specificFileEnterAutoCmd)
    else
      return nil
    end
  end
  specificFileEnterAutoCmd = A.nvim_create_autocmd("BufReadPost", {callback = _2_})
end
vim.cmd("colorscheme morimo")
return (require("config-local")).setup({silent = true})
