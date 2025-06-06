-- [nfnl] Compiled from fnl/hook-edit.fnl by https://github.com/Olical/nfnl, do not edit.
for k, v in pairs({expandtab = true, tabstop = 2, shiftwidth = 2, showmatch = true, ph = 20, virtualedit = "block"}) do
  vim.o[k] = v
end
vim.opt.nrformats:append("unsigned")
do
  local opts = {noremap = true, silent = true}
  local cmd
  local function _1_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  cmd = _1_
  local lcmd
  local function _2_(c)
    return cmd(("lua " .. c))
  end
  lcmd = _2_
  for _, k in ipairs({{"gx", lcmd("require('open').open_cword()")}, {"<Leader>tz", cmd("NeoZoomToggle")}, {"<esc><esc>", cmd("nohl")}, {"j", "gj"}, {"k", "gk"}, {"<C-h>", lcmd("require('foldnav').goto_start()")}, {"<C-j>", lcmd("require('foldnav').goto_next()")}, {"<C-k>", lcmd("require('foldnav').goto_prev_start()")}, {"<C-l>", lcmd("require('foldnav').goto_end()")}}) do
    vim.keymap.set("n", k[1], k[2], (k[3] or opts))
  end
end
local osc52 = require("vim.ui.clipboard.osc52")
local paste
local function _3_()
  return {vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("")}
end
paste = _3_
if (os.getenv("SSH_TTY") ~= nil) then
  vim.g.clipboard = {name = "OSC 52", copy = {["+"] = osc52.copy("+"), ["*"] = osc52.copy("*")}, paste = {["+"] = paste, ["*"] = paste}}
  return nil
else
  return nil
end
