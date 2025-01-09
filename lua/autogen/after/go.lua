-- [nfnl] Compiled from fnl/after/go.fnl by https://github.com/Olical/nfnl, do not edit.
vim.opt_local.expandtab = false
local opts
local function _1_(d)
  return {silent = true, buffer = true, desc = d, noremap = false}
end
opts = _1_
for mode, ks in pairs({n = {{"<LocalLeader>fi", "<Cmd>GoImplOpen<CR>", opts("\238\152\167 generate stub for I/F")}}}) do
  for _, k in ipairs(ks) do
    vim.keymap.set(mode, k[1], k[2], k[3])
  end
end
return nil
