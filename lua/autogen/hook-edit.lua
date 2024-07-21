-- [nfnl] Compiled from fnl/hook-edit.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local opts = {expandtab = true, tabstop = 2, shiftwidth = 2, showmatch = true, ph = 20, completeopt = "", virtualedit = "block"}
  for k, v in pairs(opts) do
    vim.o[k] = v
  end
end
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local cmd
local function _2_(c)
  return ("<cmd>" .. c .. "<cr>")
end
cmd = _2_
local lcmd
local function _3_(c)
  return cmd(("lua " .. c))
end
lcmd = _3_
local N = {{"gx", lcmd("require('open').open_cword()")}}
for _, k in ipairs(N) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
