-- [nfnl] Compiled from fnl/prelude.fnl by https://github.com/Olical/nfnl, do not edit.
local opts = {termguicolors = true, signcolumn = "no", showtabline = 0, foldlevel = 99, foldlevelstart = 99, showmode = false, number = false}
vim.loader.enable()
for k, v in pairs(opts) do
  vim.o[k] = v
end
return nil
