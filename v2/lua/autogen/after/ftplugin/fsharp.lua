-- [nfnl] v2/fnl/after/ftplugin/fsharp.fnl
local function _1_()
  return vim.lsp.codelens.enable(true, {bufnr = 0})
end
return vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave"}, {callback = _1_, buffer = 0})
