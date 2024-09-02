-- [nfnl] Compiled from fnl/hook-edit.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local opts = {expandtab = true, tabstop = 2, shiftwidth = 2, showmatch = true, ph = 20, completeopt = "", virtualedit = "block"}
  for k, v in pairs(opts) do
    vim.o[k] = v
  end
  vim.opt.nrformats:append("unsigned")
end
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
  local N = {{"gx", lcmd("require('open').open_cword()")}, {"<esc><esc>", cmd("nohl")}, {"j", "gj"}, {"k", "gk"}}
  for _, k in ipairs(N) do
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
